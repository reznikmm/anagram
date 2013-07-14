------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Ada.Containers.Vectors;
with Ada.Containers.Ordered_Sets;
with Ada.Containers.Ordered_Maps;
with Gela.Grammars.Constructors;
with League.Strings;
with Gela.Grammars.Rule_Templates;
with League.String_Vectors;

package body Gela.Grammars_Convertors is

   package String_Sets is new Ada.Containers.Ordered_Sets
     (League.Strings.Universal_String, League.Strings."<", League.Strings."=");

   type Rule_Info is record
      Weight : Natural;
      Text   : League.Strings.Universal_String;
   end record;

   type Derived_Production is record
      Non_Terminal : League.Strings.Universal_String;
      Name         : League.Strings.Universal_String;
      Index        : Gela.Grammars.Production_Index;
      Part_Names   : String_Sets.Set;
   end record;

   package Derived_Production_Vectors is new Ada.Containers.Vectors
     (Positive, Derived_Production);

   package Rule_Maps is new Ada.Containers.Ordered_Maps
     (League.Strings.Universal_String,
      Rule_Info,
      League.Strings."<");

   -------------
   -- Convert --
   -------------

   function Convert
     (Input : Gela.Grammars.Grammar;
      Left  : Boolean)
      return Gela.Grammars.Grammar
   is
      pragma Unreferenced (Left);
      use Gela.Grammars;

      type Plain_Production is array (Part_Index range <>) of Part_Index;

      procedure Copy_Productions
        (PL          : in out Constructors.Production_List;
         NT_Name     : S.Universal_String;
         First, Last : Production_Index);

      procedure Create_Production
        (PL        : in out Constructors.Production_List;
         NT_Name   : S.Universal_String;
         P         : Production_Index);

      procedure Create_Declarations
        (Non_Terminal : S.Universal_String;
         First, Last  : Attribute_Declaration_Count);

      procedure Copy_Rules (Derived : Derived_Production);

      function Check
        (Part_Names : String_Sets.Set;
         Attr       : Attribute_Index) return Boolean;

      procedure Fill_Part_Indexes
        (Output : out Plain_Production;
         First  : Part_Index);

      -----------------------
      -- Fill_Part_Indexes --
      -----------------------

      procedure Fill_Part_Indexes
        (Output : out Plain_Production;
         First  : Part_Index) is
      begin
         for J in Output'Range loop
            Output (J) := First + J - Output'First;
         end loop;
      end Fill_Part_Indexes;

      Output    : Gela.Grammars.Constructors.Constructor;
      Derived   : Derived_Production_Vectors.Vector;

      -------------------------
      -- Create_Declarations --
      -------------------------

      procedure Create_Declarations
        (Non_Terminal : S.Universal_String;
         First, Last  : Attribute_Declaration_Count) is
      begin
         for Declaration of Input.Declaration (First .. Last) loop
            Output.Create_Attribute_Declaration
              (Non_Terminal => Non_Terminal,
               Name         => Declaration.Name,
               Type_Name    => Declaration.Type_Name,
               Is_Inherited => Declaration.Is_Inherited);
         end loop;
      end Create_Declarations;

      -----------------------
      -- Create_Production --
      -----------------------

      procedure Create_Production
        (PL        : in out Constructors.Production_List;
         NT_Name   : S.Universal_String;
         P         : Production_Index)
      is

         procedure Create_Recursive
           (Plain : Plain_Production;
            Name  : S.Universal_String);
         --  If Plain has an option - expand it an call again.
         --  Otherwise create new production

         ----------------------
         -- Create_Recursive --
         ----------------------

         procedure Create_Recursive
           (Plain : Plain_Production;
            Name  : S.Universal_String) is
         begin
            for J in Plain'Range loop
               if Input.Part (Plain (J)).Is_Option then
                  --  Expand option
                  for K of Input.Production (Input.Part (Plain (J)).First
                                               .. Input.Part (Plain (J)).Last)
                  loop
                     declare
                        use type S.Universal_String;

                        Nested_Name : S.Universal_String := K.Name;
                        Length : constant Part_Count := K.Last - K.First + 1;
                     begin
                        if Nested_Name.Is_Empty then
                           Nested_Name := S.To_Universal_String
                             (Production_Index'Wide_Wide_Image (K.Index));
                           Nested_Name.Slice (2, Nested_Name.Length);
                        end if;

                        if not Name.Is_Empty then
                           Nested_Name := Name & "_" & Nested_Name;
                        end if;

                        declare
                           Next  : Plain_Production
                             (1 .. Plain'Length - 1 + Length);
                           Count : constant Part_Count := J - Plain'First;
                        begin
                           Next (1 .. Count) := Plain (Plain'First .. J - 1);
                           Fill_Part_Indexes
                             (Next (Count + 1 .. Count + Length), K.First);
                           Next (Count + Length + 1 .. Next'Last) :=
                             Plain (J + 1 .. Plain'Last);
                           Create_Recursive (Next, Nested_Name);
                        end;
                     end;
                  end loop;

                  --  Strip option away
                  declare
                     Next  : Plain_Production (1 .. Plain'Length - 1);
                     Count : constant Part_Count := J - Plain'First;
                  begin
                     Next (1 .. Count) := Plain (Plain'First .. J - 1);
                     Next (Count + 1 .. Next'Last) :=
                       Plain (J + 1 .. Plain'Last);
                     Create_Recursive (Next, Name);
                  end;

                  return;
               end if;
            end loop;

            Derived.Append
              ((Non_Terminal => NT_Name,
                Name         => Name,
                Index        => P,
                Part_Names   => String_Sets.Empty_Set));

            declare
               Result  : Constructors.Production := Output.Create_Production
                 (Name, Precedence (Input.Production (P)));
               Derived : Derived_Production
                 renames Convert.Derived (Convert.Derived.Last_Index);
            begin
               for Each of Plain loop
                  declare
                     Part : Grammars.Part renames Input.Part (Each);
                  begin
                     if Part.Is_Terminal_Reference then
                        Result.Add
                          (Output.Create_Terminal_Reference
                             (Name  => Part.Name,
                              Image => Input.Terminal (Part.Denote).Image));

                        Derived.Part_Names.Insert (Part.Name);

                     elsif Part.Is_Non_Terminal_Reference
                       or Part.Is_List_Reference
                     then
                        Result.Add
                          (Output.Create_Non_Terminal_Reference
                             (Denote => Input.Non_Terminal
                                (Part.Denote).Name,
                              Name   => Part.Name));

                        Derived.Part_Names.Insert (Part.Name);
                     else
                        raise Program_Error;
                     end if;
                  end;
               end loop;

               PL.Add (Result);
            end;
         end Create_Recursive;

         Length : constant Part_Count :=
           Input.Production (P).Last - Input.Production (P).First + 1;
         Plain  : Plain_Production (1 .. Length);
      begin
         Fill_Part_Indexes (Plain, Input.Production (P).First);
         Create_Recursive (Plain, Input.Production (P).Name);
      end Create_Production;

      -----------
      -- Check --
      -----------

      function Check
        (Part_Names : String_Sets.Set;
         Attr       : Attribute_Index) return Boolean is
      begin
         if Input.Attribute (Attr).Is_Left_Hand_Side or
           Input.Attribute (Attr).Has_Default
         then
            return True;
         end if;

         return Part_Names.Contains
           (Input.Part (Input.Attribute (Attr).Origin).Name);
      end Check;

      ----------------------
      -- Copy_Productions --
      ----------------------

      procedure Copy_Productions
        (PL          : in out Constructors.Production_List;
         NT_Name     : S.Universal_String;
         First, Last : Production_Index) is
      begin
         for P in First .. Last loop
            Create_Production (PL, NT_Name, P);
         end loop;
      end Copy_Productions;

      function Substitute_Default
        (Derived : Derived_Production;
         Rule    : Gela.Grammars.Rule) return S.Universal_String;

      ------------------------
      -- Substitute_Default --
      ------------------------

      function Substitute_Default
        (Derived : Derived_Production;
         Rule    : Gela.Grammars.Rule) return S.Universal_String
      is
         use type S.Universal_String;

         Values : League.String_Vectors.Universal_String_Vector;
         Text : constant S.Universal_String := Input.Rule (Rule.Index).Text;
         Template : constant Rule_Templates.Rule_Template :=
           Rule_Templates.Create (Text);
         Name : S.Universal_String;
      begin
         for J in 1 .. Template.Count loop
            Name := Template.Part_Name (J);

            if Name = Derived.Non_Terminal or else
              Derived.Part_Names.Contains (Name)
            then
               Name.Prepend ("${");
               Name.Append (".");
               Name.Append (Template.Attribute_Name (J));

               if Template.Has_Default (J) then
                  Name.Append (":");
                  Name.Append (Template.Default (J));
               end if;

               Name.Append ("}");

               Values.Append (Name);
            else
               Values.Append (Template.Default (J));
            end if;
         end loop;

         return Template.Substitute (Values);
      end Substitute_Default;

      ----------------
      -- Copy_Rules --
      ----------------

      procedure Copy_Rules (Derived : Derived_Production) is
         Prod   : Production renames Input.Production (Derived.Index);
         Map    : Rule_Maps.Map;
         X      : Attribute_Index;
         Ok     : Boolean := True;
         Weight : Natural;
         Key    : S.Universal_String;
         Text   : S.Universal_String;
      begin
         for Rule of Input.Rule (Prod.First_Rule .. Prod.Last_Rule) loop
            Ok := Check (Derived.Part_Names, Rule.Result);

            for A in Rule.First_Argument .. Rule.Last_Argument loop
               Ok := Ok and then Check (Derived.Part_Names, A);
            end loop;

            if Ok then
               Weight :=
                 Natural (Rule.Last_Argument - Rule.First_Argument + 1);

               X := Rule.Result;

               if Input.Attribute (X).Is_Left_Hand_Side then
                  Key := S.Empty_Universal_String;
               else
                  Key := Input.Part (Input.Attribute (X).Origin).Name;
               end if;

               Key.Append (" ");

               Key.Append (Input.Declaration
                           (Input.Attribute (X).Declaration).Name);

               Text := Substitute_Default (Derived, Rule);

               if Map.Contains (Key) then
                  if Map (Key).Weight < Weight then
                     Map (Key) := (Weight, Text);
                  end if;
               else
                  Map.Insert (Key, (Weight, Text));
               end if;
            end if;
         end loop;

         for Rule_Info of Map loop
            Output.Create_Rule
              (Non_Terminal => Derived.Non_Terminal,
               Production   => Derived.Name,
               Text         => Rule_Info.Text);
         end loop;
      end Copy_Rules;

   begin
      for Terminal of Input.Terminal loop
         Output.Create_Terminal (Terminal.Image, Precedence (Terminal));

         for Declaration of Input.Declaration
           (Terminal.First_Attribute .. Terminal.Last_Attribute)
         loop
            Output.Create_Attribute_Declaration
              (Name      => Declaration.Name,
               Type_Name => Declaration.Type_Name,
               Terminal  => Terminal.Image);
         end loop;
      end loop;

      for Non_Terminal of Input.Non_Terminal loop
         declare
            PL : Constructors.Production_List := Output.Create_Production_List;
         begin
            Copy_Productions
              (PL,
               Non_Terminal.Name,
               Non_Terminal.First,
               Non_Terminal.Last);

            Output.Create_Non_Terminal (Non_Terminal.Name, PL);

            Create_Declarations
              (Non_Terminal.Name,
               Non_Terminal.First_Attribute,
               Non_Terminal.Last_Attribute);
         end;
      end loop;

      for Derived_Production of Derived loop
         Copy_Rules (Derived_Production);
      end loop;

--      Output.Set_With_List (Input.With_List);

      return Output.Complete;
   end Convert;

   ------------------------
   -- Convert_With_Empty --
   ------------------------

   function Convert_With_Empty
     (Input : Gela.Grammars.Grammar)
      return Gela.Grammars.Grammar
   is
      use Gela.Grammars;

      type Part_Order is ('<', '>', '=');

      function Less (Left, Right : Part_Index) return Part_Order;
      function Less (Left, Right : Part_Index) return Boolean;

      procedure Create_Option (P : Part);

      procedure Copy_Production
        (PL    : in out Constructors.Production_List;
         Index : Production_Index);

      procedure Copy_Productions
        (PL          : in out Constructors.Production_List;
         First, Last : Production_Index);

      package Opt_Map is new Ada.Containers.Ordered_Maps
        (Part_Index,
         League.Strings.Universal_String,
         "<" => Less,
         "=" => League.Strings."=");

      Output    : Gela.Grammars.Constructors.Constructor;
      Options   : Opt_Map.Map;

      ---------------------
      -- Copy_Production --
      ---------------------

      procedure Copy_Production
        (PL    : in out Constructors.Production_List;
         Index : Production_Index)
      is
         P      : Production renames Input.Production (Index);
         Result : Constructors.Production := Output.Create_Production (P.Name);
      begin
         for Part of Input.Part (P.First .. P.Last) loop
            if Part.Is_Option then
               Create_Option (Part);
               Result.Add
                 (Output.Create_Non_Terminal_Reference
                    (Part.Name, Options (Part.Index)));
            elsif Part.Is_Terminal_Reference then
               Result.Add
                 (Output.Create_Terminal_Reference
                    (Part.Name, Input.Terminal (Part.Denote).Image));
            else
               Result.Add
                 (Output.Create_Non_Terminal_Reference
                    (Part.Name, Input.Non_Terminal (Part.Denote).Name));
            end if;
         end loop;

         PL.Add (Result);
      end Copy_Production;

      ----------------------
      -- Copy_Productions --
      ----------------------

      procedure Copy_Productions
        (PL          : in out Constructors.Production_List;
         First, Last : Production_Index) is
      begin
         for P in First .. Last loop
            Copy_Production (PL, P);
         end loop;
      end Copy_Productions;

      -------------------
      -- Create_Option --
      -------------------

      procedure Create_Option (P : Part) is
      begin
         if Options.Contains (P.Index) then
            return;
         end if;

         declare
            use type Ada.Containers.Count_Type;

            PL    : Constructors.Production_List :=
              Output.Create_Production_List;
            Name  : League.Strings.Universal_String :=
              League.Strings.To_Universal_String ("option");
            Image : Wide_Wide_String :=
              Ada.Containers.Count_Type'Wide_Wide_Image (Options.Length + 1);
            Empty : constant League.Strings.Universal_String :=
              League.Strings.To_Universal_String ("empty");
         begin
            Image (1) := '_';
            Name.Append (Image);
            Options.Insert (P.Index, Name);

            PL.Add (Output.Create_Production (Empty));

            Copy_Productions
              (PL,
               P.First,
               P.Last);

            Output.Create_Non_Terminal (Name, PL);
         end;
      end Create_Option;

      ----------
      -- Less --
      ----------

      function Less (Left, Right : Part_Index) return Part_Order is
         M : constant array (Boolean) of Part_Order := ('>', '<');
         L : Part renames Input.Part (Left);
         R : Part renames Input.Part (Right);
      begin
         if L.Last - L.First /= R.Last - R.First then
            return M (L.Last - L.First < R.Last - R.First);
         end if;

         for P in L.First .. L.Last loop
            declare
               L_Prod : Production renames Input.Production (P);
               R_Prod : Production renames
                 Input.Production (P - L.First + R.First);
            begin
               if L_Prod.Last - L_Prod.First /= R_Prod.Last - R_Prod.First then
                  return M
                    (L_Prod.Last - L_Prod.First < R_Prod.Last - R_Prod.First);
               end if;

               for J in L_Prod.First .. L_Prod.Last loop
                  declare
                     L_Part : Part renames Input.Part (J);
                     R_Part : Part renames
                       Input.Part (J - L_Prod.First + R_Prod.First);
                  begin
                     if L_Part.Is_Option /= R_Part.Is_Option then
                        return M (L_Part.Is_Option < R_Part.Is_Option);
                     elsif L_Part.Is_Terminal_Reference /=
                       R_Part.Is_Terminal_Reference
                     then
                        return M (L_Part.Is_Terminal_Reference <
                          R_Part.Is_Terminal_Reference);
                     end if;

                     if L_Part.Is_Option then
                        declare
                           Compare : constant Part_Order :=
                             Less (L_Part.Index, R_Part.Index);
                        begin
                           if Compare /= '=' then
                              return Compare;
                           end if;
                        end;
                     elsif L_Part.Is_Terminal_Reference then
                        if Terminal_Count'(L_Part.Denote) /= R_Part.Denote then
                           return M (Terminal_Count'(L_Part.Denote) <
                                       R_Part.Denote);
                        end if;
                     else
                        if Non_Terminal_Count'(L_Part.Denote) /=
                          R_Part.Denote
                        then
                           return M (Non_Terminal_Count'(L_Part.Denote) <
                                       R_Part.Denote);
                        end if;
                     end if;
                  end;
               end loop;
            end;
         end loop;

         return '=';
      end Less;

      ----------
      -- Less --
      ----------

      function Less (Left, Right : Part_Index) return Boolean is
      begin
         return Less (Left, Right) = '<';
      end Less;

   begin
      for Terminal of Input.Terminal loop
         Output.Create_Terminal (Terminal.Image);

         for Declaration of Input.Declaration
           (Terminal.First_Attribute .. Terminal.Last_Attribute)
         loop
            Output.Create_Attribute_Declaration
              (Name      => Declaration.Name,
               Type_Name => Declaration.Type_Name,
               Terminal  => Terminal.Image);
         end loop;
      end loop;

      for Non_Terminal of Input.Non_Terminal loop
         declare
            PL : Constructors.Production_List := Output.Create_Production_List;
         begin
            Copy_Productions
              (PL,
               Non_Terminal.First,
               Non_Terminal.Last);

            Output.Create_Non_Terminal (Non_Terminal.Name, PL);

--              Create_Declarations
--                (Non_Terminal.Name,
--                 Non_Terminal.First_Attribute,
--                 Non_Terminal.Last_Attribute);
         end;
      end loop;
      return Output.Complete;
   end Convert_With_Empty;

end Gela.Grammars_Convertors;