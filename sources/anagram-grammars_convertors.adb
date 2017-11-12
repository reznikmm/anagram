--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Ada.Containers.Vectors;
with Ada.Containers.Ordered_Sets;
with Ada.Containers.Ordered_Maps;
with Anagram.Grammars.Constructors;
with League.Strings;
with Anagram.Grammars.Rule_Templates;
with League.String_Vectors;

package body Anagram.Grammars_Convertors is

   package String_Sets is new Ada.Containers.Ordered_Sets
     (League.Strings.Universal_String, League.Strings."<", League.Strings."=");

   type Rule_Info is record
      Weight : Natural;
      Text   : League.Strings.Universal_String;
   end record;

   type Derived_Production is record
      Non_Terminal : League.Strings.Universal_String;
      Name         : League.Strings.Universal_String;
      Index        : Anagram.Grammars.Production_Index;
      Part_Names   : String_Sets.Set;
   end record;

   package Derived_Production_Vectors is new Ada.Containers.Vectors
     (Positive, Derived_Production);

   package Rule_Maps is new Ada.Containers.Ordered_Maps
     (League.Strings.Universal_String,
      Rule_Info,
      League.Strings."<");

   procedure Create_Declarations
     (Input  : Anagram.Grammars.Grammar;
      Output : in out Anagram.Grammars.Constructors.Constructor;
      NT     : Anagram.Grammars.Non_Terminal);

   Empty_List_Name : constant League.Strings.Universal_String :=
     League.Strings.To_Universal_String ("empty_list");

   -------------
   -- Convert --
   -------------

   function Convert
     (Input : Anagram.Grammars.Grammar;
      Left  : Boolean)
      return Anagram.Grammars.Grammar
   is
      pragma Unreferenced (Left);
      use Anagram.Grammars;

      type Plain_Part is record
         Source   : Part_Index;
         Expanded : Boolean := False;
         --  If Source if list_reference and Expanded = True then Source is
         --  already expanded, skip it
      end record;

      type Plain_Production is array (Part_Index range <>) of Plain_Part;

      procedure Copy_Productions
        (PL          : in out Constructors.Production_List;
         NT_Name     : S.Universal_String;
         First, Last : Production_Index);

      procedure Create_Production
        (PL        : in out Constructors.Production_List;
         NT_Name   : S.Universal_String;
         P         : Production_Index);

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
            Output (J).Source := First + J - Output'First;
            Output (J).Expanded := False;
         end loop;
      end Fill_Part_Indexes;

      Output    : Anagram.Grammars.Constructors.Constructor;
      Derived   : Derived_Production_Vectors.Vector;

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
         --  If Plain has an option or list_ref - expand it and call again.
         --  Otherwise create new production

         ----------------------
         -- Create_Recursive --
         ----------------------

         procedure Create_Recursive
           (Plain : Plain_Production;
            Name  : S.Universal_String)
         is
            use type S.Universal_String;

            procedure Remove_This_Away (J : Part_Index);
            --  Remove J item from Plain and call Create_Recursive again

            ----------------------
            -- Remove_This_Away --
            ----------------------

            procedure Remove_This_Away (J : Part_Index) is
               Next  : Plain_Production (1 .. Plain'Length - 1);
               Count : constant Part_Count := J - Plain'First;
            begin
               Next (1 .. Count) := Plain (Plain'First .. J - 1);
               Next (Count + 1 .. Next'Last) :=
                 Plain (J + 1 .. Plain'Last);
               Create_Recursive (Next, Name);
            end Remove_This_Away;

            Source : Part_Index;
         begin
            for J in Plain'Range loop
               Source := Plain (J).Source;
               if Input.Part (Source).Is_Option then
                  --  Expand option
                  for K of Input.Production (Input.Part (Source).First
                                               .. Input.Part (Source).Last)
                  loop
                     declare
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
                  Remove_This_Away (J);

                  return;
               elsif Input.Part (Source).Is_List_Reference
                 and not Plain (J).Expanded
               then
                  --  Mark list ref as expanded an try again
                  declare
                     Next        : Plain_Production := Plain;
                     Nested_Name : S.Universal_String :=
                       Input.Part (Source).Name;
                  begin
                     if Nested_Name.Is_Empty then
                        raise Constraint_Error;
                     end if;

                     if not Name.Is_Empty then
                        Nested_Name := Name & "_" & Nested_Name;
                     end if;

                     Next (J).Expanded := True;
                     Create_Recursive (Next, Nested_Name);
                  end;

                  --  Strip away list reference away
                  Remove_This_Away (J);
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
                     Part : Grammars.Part renames Input.Part (Each.Source);
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
         Rule    : Anagram.Grammars.Rule) return S.Universal_String;

      ------------------------
      -- Substitute_Default --
      ------------------------

      function Substitute_Default
        (Derived : Derived_Production;
         Rule    : Anagram.Grammars.Rule) return S.Universal_String
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

            Create_Declarations (Input, Output, Non_Terminal);
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
     (Input : Anagram.Grammars.Grammar)
      return Anagram.Grammars.Grammar
   is
      use Anagram.Grammars;

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

      function Is_LHS_Only (R : Anagram.Grammars.Rule) return Boolean;

      Output    : Anagram.Grammars.Constructors.Constructor;
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

      -----------------
      -- Is_LHS_Only --
      -----------------

      function Is_LHS_Only (R : Anagram.Grammars.Rule) return Boolean is
      begin
         if not Input.Attribute (R.Result).Is_Left_Hand_Side then
            return False;
         end if;

         for J in R.First_Argument .. R.Last_Argument loop
            if not Input.Attribute (J).Is_Left_Hand_Side then
               return False;
            end if;
         end loop;

         return True;
      end Is_LHS_Only;

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

      Has_Non_Empty_Rule  : array (Input.Declaration'Range) of Boolean :=
        (others => False);
      Empty_Rule : array (Input.Rule'Range) of Boolean := (others => False);

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

            if Non_Terminal.Is_List then
               PL.Add (Output.Create_Production
                         (Name => Empty_List_Name));
            end if;

            Output.Create_Non_Terminal (Non_Terminal.Name, PL);

            Create_Declarations (Input, Output, Non_Terminal);
         end;
      end loop;

      for R of Input.Rule loop
         declare
            Prod : Production renames Input.Production (R.Parent);
            NT   : Non_Terminal renames Input.Non_Terminal (Prod.Parent);
         begin
            if NT.Is_List then
               if Is_LHS_Only (R) then
                  Empty_Rule (R.Index) := True;
               else
                  Has_Non_Empty_Rule
                    (Input.Attribute (R.Result).Declaration) := True;
               end if;
            end if;
         end;
      end loop;

      for R of Input.Rule loop
         declare
            Prod : Production renames Input.Production (R.Parent);
            NT   : Non_Terminal renames Input.Non_Terminal (Prod.Parent);
            Attr : Attribute renames Input.Attribute (R.Result);
         begin
            if not (NT.Is_List and Empty_Rule (R.Index)
                    and Has_Non_Empty_Rule (Attr.Declaration))
            then
               Output.Create_Rule (NT.Name, Prod.Name, R.Text);
            end if;

            if NT.Is_List and Empty_Rule (R.Index) then
               Output.Create_Rule (NT.Name, Empty_List_Name, R.Text);
            end if;
         end;
      end loop;

      return Output.Complete;
   end Convert_With_Empty;

   -------------------------
   -- Create_Declarations --
   -------------------------

   procedure Create_Declarations
     (Input  : Anagram.Grammars.Grammar;
      Output : in out Anagram.Grammars.Constructors.Constructor;
      NT     : Anagram.Grammars.Non_Terminal) is
   begin
      for Declaration of Input.Declaration
        (NT.First_Attribute .. NT.Last_Attribute)
      loop
         Output.Create_Attribute_Declaration
           (Non_Terminal => NT.Name,
            Name         => Declaration.Name,
            Type_Name    => Declaration.Type_Name,
            Is_Inherited => Declaration.Is_Inherited);
      end loop;
   end Create_Declarations;

end Anagram.Grammars_Convertors;
