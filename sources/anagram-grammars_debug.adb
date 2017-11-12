--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Ada.Wide_Wide_Text_IO;
with Anagram.Grammars.LR;

package body Anagram.Grammars_Debug is

   -----------
   -- Print --
   -----------

   procedure Print (Self : Anagram.Grammars.Grammar) is
      use Ada.Wide_Wide_Text_IO;
      use Anagram.Grammars;

      procedure Print_Attr (Attr : Attribute_Index);
      procedure Print_Productions (First, Last : Production_Count);
      procedure Print_Declarations (First, Last : Attribute_Declaration_Count);
      function Is_List (X : Boolean) return Wide_Wide_String;

      procedure Print_Attr (Attr : Attribute_Index) is
      begin
         if Self.Attribute (Attr).Is_Left_Hand_Side then
            Put ("LHS.");
         else
            Put (Self.Part (Self.Attribute (Attr).Origin).Name.
                   To_Wide_Wide_String & ".");
         end if;

         Put_Line (Self.Declaration (Self.Attribute (Attr).Declaration).Name.
                     To_Wide_Wide_String);
      end Print_Attr;

      procedure Print_Declarations
        (First, Last : Attribute_Declaration_Count) is
      begin
         for D in First .. Last loop
            Put_Line
              ("  Attr: " & Self.Declaration (D).Name.To_Wide_Wide_String &
                 " inherited=" &
                 Boolean'Wide_Wide_Image (Self.Declaration (D).Is_Inherited));
         end loop;
      end Print_Declarations;

      procedure Print_Productions (First, Last : Production_Count) is
      begin
         for P in First .. Last loop
            Put_Line ("  Production: " &
                        Self.Production (P).Name.To_Wide_Wide_String &
                      " (" & Production_Index'Wide_Wide_Image (P) & ")");

            for R in Part_Count'(Self.Production (P).First) ..
              Self.Production (P).Last
            loop
               Put ("    " & Self.Part (R).Name.To_Wide_Wide_String);

               if Self.Part (R).Is_Terminal_Reference then
                  Put_Line (" refs " & Self.Terminal (Self.Part (R).Denote)
                              .Image.To_Wide_Wide_String);
               elsif Self.Part (R).Is_Non_Terminal_Reference then
                  Put_Line (" refs " & Self.Non_Terminal (Self.Part (R).Denote)
                              .Name.To_Wide_Wide_String);
               else
                  if Self.Part (R).Is_List_Reference then
                     Put_Line (" List:" &
                                 Self.Non_Terminal (Self.Part (R).Denote)
                                   .Name.To_Wide_Wide_String);
                  else
                     Put_Line (" Option:");

                     Print_Productions
                       (Self.Part (R).First, Self.Part (R).Last);

                     Put_Line (" End");
                  end if;
               end if;
            end loop;

            for R in Self.Production (P).First_Rule ..
              Self.Production (P).Last_Rule
            loop
               Put_Line ("Rule: ");
               Put ("  Result: ");
               Print_Attr (Self.Rule (R).Result);

               for A in Self.Rule (R).First_Argument ..
                 Self.Rule (R).Last_Argument
               loop
                  Put ("  Arg: ");
                  Print_Attr (A);
               end loop;
            end loop;
         end loop;
      end Print_Productions;

      function Is_List (X : Boolean) return Wide_Wide_String is
      begin
         if X then
            return " (List)";
         else
            return "";
         end if;
      end Is_List;
   begin
      Put_Line ("Terminals:");

      for J in 1 .. Self.Last_Terminal loop
         Put_Line (Terminal_Count'Wide_Wide_Image (J) & " " &
                     Self.Terminal (J).Image.To_Wide_Wide_String);

         Print_Declarations
           (Self.Terminal (J).First_Attribute,
            Self.Terminal (J).Last_Attribute);
      end loop;

      Put_Line ("Non Terminals:");

      for J in 1 .. Self.Last_Non_Terminal loop
         Put_Line (Non_Terminal_Count'Wide_Wide_Image (J) & " " &
                     Self.Non_Terminal (J).Name.To_Wide_Wide_String &
                     Is_List (Self.Non_Terminal (J).Is_List));

         Print_Declarations
           (Self.Non_Terminal (J).First_Attribute,
            Self.Non_Terminal (J).Last_Attribute);

         Print_Productions
           (Self.Non_Terminal (J).First, Self.Non_Terminal (J).Last);
      end loop;
   end Print;

   ---------------------
   -- Print_Conflicts --
   ---------------------

   procedure Print_Conflicts (Self  : Anagram.Grammars.Grammar;
                              Table : Anagram.Grammars.LR_Tables.Table)
   is
      use Ada.Wide_Wide_Text_IO;
      use Anagram.Grammars.LR_Tables;
      use type Anagram.Grammars.LR.State_Count;

      procedure Print_State (State : Anagram.Grammars.LR.State_Index);
      procedure Print_Reduce
        (Prefix : Wide_Wide_String;
         R      : in out Reduce_Iterator);
      procedure Print_Conflict
        (Prefix : Wide_Wide_String;
         T      : Anagram.Grammars.Terminal_Count);

      ------------------
      -- Print_Reduce --
      ------------------

      procedure Print_Reduce
        (Prefix : Wide_Wide_String;
         R      : in out Reduce_Iterator)
      is
         P  : Anagram.Grammars.Production_Index;
         NT : Anagram.Grammars.Non_Terminal_Index;
      begin
         while not Is_Empty (R) loop
            P := Production (R);
            NT := Self.Production (P).Parent;

            Put_Line
              (Prefix & "Non terminal "
               & Self.Non_Terminal (NT).Name.To_Wide_Wide_String
               & " production "
               & Self.Production (P).Name.To_Wide_Wide_String);

            Next (Table, R);
         end loop;
      end Print_Reduce;

      -----------------
      -- Print_State --
      -----------------

      procedure Print_State (State : Anagram.Grammars.LR.State_Index) is
      begin
         Put_Line
           ("State:" &
              Anagram.Grammars.LR.State_Index'Wide_Wide_Image (State));
      end Print_State;

      procedure Print_Conflict
        (Prefix : Wide_Wide_String;
         T      : Anagram.Grammars.Terminal_Count)
      is
         use type Anagram.Grammars.Terminal_Count;
      begin
         if T = 0 then
            Put_Line (Prefix & " conflict on token End_Of_File");
         else
            Put_Line
              (Prefix & " conflict on token '"
               & Self.Terminal (T).Image.To_Wide_Wide_String
               & "'");
         end if;
      end Print_Conflict;

      State_Printed : Boolean;

      S : Anagram.Grammars.LR.State_Count;
      R : Reduce_Iterator;
   begin
      for State in 1 .. Last_State (Table) loop
         State_Printed := False;

         for T in 0 .. Self.Last_Terminal loop
            S := Shift (Table, State, T);
            R := Reduce (Table, State, T);

            if S /= 0 then
               if not Is_Empty (R) then
                  if not State_Printed then
                     State_Printed := True;
                     Print_State (State);
                  end if;

                  Print_Conflict ("Shift/Reduce", T);

                  Put ("Shift to ");
                  Print_State (S);
                  Print_Reduce ("Shift/Reduce ", R);
               end if;
            elsif not Is_Empty (R) then
               declare
                  Save : Reduce_Iterator := R;
               begin
                  Next (Table, R);

                  if not Is_Empty (R) then
                     if not State_Printed then
                        State_Printed := True;
                        Print_State (State);
                     end if;

                     Print_Conflict ("Reduce/Reduce", T);

                     Print_Reduce ("Reduce/Reduce ", Save);
                  end if;
               end;
            end if;
         end loop;
      end loop;
   end Print_Conflicts;

end Anagram.Grammars_Debug;
