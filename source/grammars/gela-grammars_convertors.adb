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
with Gela.Grammars.Attributed.Constructors;
with League.Strings;

package body Gela.Grammars_Convertors is

   package Production_Vectors is new Ada.Containers.Vectors
     (Gela.Grammars.Part_Index,
      Gela.Grammars.Production_Count,
      Gela.Grammars."=");

   package String_Sets is new Ada.Containers.Ordered_Sets
     (League.Strings.Universal_String, League.Strings."<", League.Strings."=");

   type Rule_Info is record
      Weight : Natural;
      Index  : Gela.Grammars.Attributed.Rule_Index;
   end record;

   package Rule_Maps is new Ada.Containers.Ordered_Maps
     (League.Strings.Universal_String,
      Rule_Info,
      League.Strings."<");

   -------------
   -- Convert --
   -------------

   function Convert
     (Input : access Gela.Grammars.Attributed.Extended.Grammar;
      Left  : Boolean)
     return Gela.Grammars.Attributed.Grammar
   is
      use Gela.Grammars;
      use Gela.Grammars.Attributed;

      procedure Copy_Productions
        (First, Last : Production_Index;
         List_NT     : S.Universal_String := S.Empty_Universal_String);

      procedure Create_Production
        (P         : Production_Index;
         Name      : S.Universal_String;
         Processed : Production_Vectors.Vector;
         List_NT   : S.Universal_String := S.Empty_Universal_String);

      procedure Create_Declarations
        (First, Last : Attribute_Declaration_Count);

      procedure Create_Lists (First, Last : Production_Index);

      Output    : Gela.Grammars.Attributed.Constructors.Constructor;
      Processed : Production_Vectors.Vector;

      procedure Create_Declarations
        (First, Last : Attribute_Declaration_Count) is
      begin
         for Attr in First .. Last loop
            Output.Create_Attribute_Declaration
              (Name      => Input.Declaration (Attr).Name,
               Type_Name => Input.Declaration (Attr).Type_Name,
               Inherited => Input.Declaration (Attr).Is_Inherited);
         end loop;
      end Create_Declarations;

      ------------------
      -- Create_Lists --
      ------------------

      procedure Create_Lists (First, Last : Production_Index) is
         procedure Create_Lists (First, Last : Part_Index);
         procedure Create_Lists (First, Last : Part_Index) is
            use type S.Universal_String;
         begin
            for J in First .. Last loop
               if Input.Part (J).Is_Option then
                  Create_Lists (Input.Part (J).First, Input.Part (J).Last);
               elsif Input.Part (J).Is_List then
                  Create_Lists (Input.Part (J).First, Input.Part (J).Last);
                  Output.Create_Non_Terminal (Input.Part (J).Name);

                  Create_Declarations
                    (Input.Part (J).First, Input.Part (J).Last);

                  Output.Create_Production
                    (Input.Part (J).Name & ".Empty");

                  Copy_Productions
                    (Input.Part (J).First,
                     Input.Part (J).Last,
                     Input.Part (J).Name);
               end if;
            end loop;
         end Create_Lists;
      begin
         for J in First .. Last loop
            Create_Lists
              (Input.Production (J).First,
               Input.Production (J).Last);
         end loop;
      end Create_Lists;

      procedure Create_Production
        (P         : Production_Index;
         Name      : S.Universal_String;
         Processed : Production_Vectors.Vector;
         List_NT   : S.Universal_String := S.Empty_Universal_String)
      is
         procedure Create_Recursive
           (Nested    : Production_Index;
            Name      : S.Universal_String;
            Processed : Production_Vectors.Vector);

         procedure Copy_Recursive
           (Nested    : Production_Index;
            Processed : Production_Vectors.Vector);

         procedure Copy_Rules (First, Last : Rule_Count);
         procedure Create_Rule (R : Rule_Index);

         function Check (Attr : Attribute_Index) return Boolean;

         procedure Copy_Attr (First, Last : Attribute_Count);

         Part_Names : String_Sets.Set;

         function Check (Attr : Attribute_Index) return Boolean is
         begin
            if Input.Attribute (Attr).Is_Left_Hand_Side then
               return True;
            end if;

            return Part_Names.Contains
              (Input.Part (Input.Attribute (Attr).Origin).Name);
         end Check;

         procedure Copy_Attr (First, Last : Attribute_Count) is
         begin
            for J in First .. Last loop
               if Input.Attribute (J).Is_Left_Hand_Side then
                  Output.Create_Argument
                    (Input.Declaration
                          (Input.Attribute (J).Declaration).Name);
               else
                  Output.Create_Argument
                    (Name => Input.Declaration
                       (Input.Attribute (J).Declaration).Name,
                     Part => Input.Part
                       (Input.Attribute (J).Origin).Name);
               end if;
            end loop;
         end Copy_Attr;

         procedure Copy_Recursive
           (Nested    : Production_Index;
            Processed : Production_Vectors.Vector) is
         begin
            for J in Part_Count'(Input.Production (Nested).First)
              .. Input.Production (Nested).Last
            loop
               if Input.Part (J).Is_Terminal_Reference then
                  Output.Create_Terminal_Reference
                    (Name  => Input.Part (J).Name,
                     Image => Input.Terminal (Input.Part (J).Denote).Image);

                  Part_Names.Insert (Input.Part (J).Name);

               elsif Input.Part (J).Is_Non_Terminal_Reference then
                  Output.Create_Non_Terminal_Reference
                    (Denote => Input.Non_Terminal
                       (Input.Part (J).Denote).Name,
                     Name   => Input.Part (J).Name);

                  Part_Names.Insert (Input.Part (J).Name);

               elsif Input.Part (J).Is_Option then
                  if Processed.Element (J) /= 0 then
                     Copy_Recursive (Processed.Element (J), Processed);
                  end if;
               elsif Input.Part (J).Is_List then
                  Output.Create_Non_Terminal_Reference
                    (Denote => Input.Part (J).Name,
                     Name   => Input.Part (J).Name);

                  Part_Names.Insert (Input.Part (J).Name);
               end if;
            end loop;
         end Copy_Recursive;

         procedure Copy_Rules (First, Last : Rule_Count) is
            Map : Rule_Maps.Map;
            X   : Attribute_Index;
            Ok  : Boolean := True;
            Weight : Natural;
            Key    : S.Universal_String;
            Pos : Rule_Maps.Cursor;
         begin
            for J in First .. Last loop
               Ok := Check (Input.Rule (J).Result);

               for A in Input.Rule (J).Argument_First
                 .. Input.Rule (J).Argument_Last
               loop
                  Ok := Ok and then Check (A);
               end loop;

               if Ok then
                  Weight := Natural (Input.Rule (J).Argument_Last -
                                       Input.Rule (J).Argument_First + 1);

                  X := Input.Rule (J).Result;

                  if not Input.Attribute (X).Is_Left_Hand_Side then
                     Key := Input.Part (Input.Attribute (X).Origin).Name;
                  end if;

                  Key.Append (" ");

                  Key.Append (Input.Declaration
                                (Input.Attribute (X).Declaration).Name);

                  Pos := Map.Find (Key);

                  if Rule_Maps.Has_Element (Pos) then
                     if Rule_Maps.Element (Pos).Weight < Weight then
                        Map.Replace_Element (Pos, (Weight, J));
                     end if;
                  else
                     Map.Insert (Key, (Weight, J));
                  end if;
               end if;
            end loop;

            Pos := Map.First;

            while Rule_Maps.Has_Element (Pos) loop
               Create_Rule (Rule_Maps.Element (Pos).Index);
               Pos := Rule_Maps.Next (Pos);
            end loop;
         end Copy_Rules;

         procedure Create_Rule (R : Rule_Index) is
            X   : constant Attribute_Index := Input.Rule (R).Result;
         begin
            if Input.Attribute (X).Is_Left_Hand_Side then
               Output.Create_Rule
                 (Input.Declaration
                    (Input.Attribute (X).Declaration).Name,
                  Input.Rule (R).Template.Text);
            else
               Output.Create_Rule
                 (Result => Input.Declaration
                    (Input.Attribute (X).Declaration).Name,
                  Part => Input.Part
                    (Input.Attribute (X).Origin).Name,
                  Text => Input.Rule (R).Template.Text);
            end if;

            Copy_Attr (Input.Rule (R).Argument_First,
                       Input.Rule (R).Argument_Last);
         end Create_Rule;

         procedure Create_Recursive
           (Nested    : Production_Index;
            Name      : S.Universal_String;
            Processed : Production_Vectors.Vector)
         is
            use type S.Universal_String;
            Next : Production_Vectors.Vector;
         begin
            for J in Part_Count'(Input.Production (Nested).First)
              .. Input.Production (Nested).Last
            loop
               if Input.Part (J).Is_Option then
                  if Processed.Element (J) = 0 then
                     Next := Processed;

                     for K in Production_Count'(Input.Part (J).First)
                              .. Input.Part (J).Last
                     loop
                        declare
                           Nested_Name : constant S.Universal_String :=
                             Name & "." & Input.Production (K).Name;
                        begin
                           Next.Replace_Element (J, K);
                           Create_Production (P, Nested_Name, Next);
                           Create_Recursive (K, Nested_Name, Next);
                        end;
                     end loop;
                  end if;
               end if;
            end loop;
         end Create_Recursive;

      begin
         Create_Recursive (P, Name, Processed);
         Output.Create_Production (Name);

         if not List_NT.Is_Empty and not Left then
            Output.Create_Non_Terminal_Reference
              (Denote => List_NT,
               Name   => List_NT);
         end if;

         Copy_Recursive (P, Processed);

         if not List_NT.Is_Empty and Left then
            Output.Create_Non_Terminal_Reference
              (Denote => List_NT,
               Name   => List_NT);
         end if;

         Copy_Rules (Input.Production (P).First, Input.Production (P).Last);
      end Create_Production;

      procedure Copy_Productions
        (First, Last : Production_Index;
         List_NT     : S.Universal_String := S.Empty_Universal_String)
      is
         use type S.Universal_String;

         Processed : constant Production_Vectors.Vector :=
           Production_Vectors.To_Vector
             (New_Item => 0, Length => Input.Part'Length);
      begin
         for P in First .. Last loop
            if List_NT.Is_Empty then
               Create_Production (P, Input.Production (P).Name, Processed);
            else
               Create_Production
                 (P,
                  Input.Production (P).Name & ".next",
                  Processed,
                  List_NT);
            end if;
         end loop;
      end Copy_Productions;
   begin
      Processed.Append (0, Input.Part'Length);

      for J in Input.Terminal'Range loop
         Output.Create_Terminal (Input.Terminal (J).Image);

         for Attr in Input.Terminal (J).First .. Input.Terminal (J).Last loop
            Output.Create_Attribute_Declaration
              (Name      => Input.Declaration (Attr).Name,
               Type_Name => Input.Declaration (Attr).Type_Name,
               Terminal  => Input.Terminal (J).Image);
         end loop;
      end loop;

      for J in Input.Non_Terminal'Range loop
         Create_Lists
           (Input.Non_Terminal (J).First,
            Input.Non_Terminal (J).Last);

         Output.Create_Non_Terminal (Input.Non_Terminal (J).Name);

         Create_Declarations
           (Input.Non_Terminal (J).First,
            Input.Non_Terminal (J).Last);

         Copy_Productions
           (Input.Non_Terminal (J).First,
            Input.Non_Terminal (J).Last);
      end loop;

      return Output.Complete;
   end Convert;

end Gela.Grammars_Convertors;
