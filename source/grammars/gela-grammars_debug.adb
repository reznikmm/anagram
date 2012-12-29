------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Ada.Wide_Wide_Text_IO;
with Gela.Grammars.LR;

package body Gela.Grammars_Debug is

   -----------
   -- Print --
   -----------

   procedure Print (Self : Gela.Grammars.Grammar) is
      use Ada.Wide_Wide_Text_IO;
      use Gela.Grammars;

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

   procedure Print_Conflicts (Self  : Gela.Grammars.Grammar;
                              Table : Gela.Grammars.LR_Tables.Table)
   is
      use Ada.Wide_Wide_Text_IO;
      use Gela.Grammars.LR_Tables;
      use type Gela.Grammars.LR.State_Count;

      procedure Print_State (State : Gela.Grammars.LR.State_Index);
      procedure Print_Reduce (R : in out Reduce_Iterator);

      ------------------
      -- Print_Reduce --
      ------------------

      procedure Print_Reduce (R : in out Reduce_Iterator) is
         P  : Gela.Grammars.Production_Index;
         NT : Gela.Grammars.Non_Terminal_Index;
      begin
         while not Is_Empty (R) loop
            P := Production (R);
            NT := Self.Production (P).Parent;

            Put_Line
              ("Non terminal "
               & Self.Non_Terminal (NT).Name.To_Wide_Wide_String
               & " production "
               & Self.Production (P).Name.To_Wide_Wide_String);

            Next (Table, R);
         end loop;
      end Print_Reduce;

      -----------------
      -- Print_State --
      -----------------

      procedure Print_State (State : Gela.Grammars.LR.State_Index) is
      begin
         Put_Line
           ("State:" & Gela.Grammars.LR.State_Index'Wide_Wide_Image (State));
      end Print_State;

      State_Printed : Boolean;

      S : Gela.Grammars.LR.State_Count;
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

                  Put_Line
                    ("Shift/Reduce conflict on token '"
                     & Self.Terminal (T).Image.To_Wide_Wide_String
                     & "'");

                  Put ("Shift to ");
                  Print_State (S);
                  Put ("Reduce to ");
                  Print_Reduce (R);
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

                        Put_Line
                          ("Reduce/Reduce conflict on token '"
                           & Self.Terminal (T).Image.To_Wide_Wide_String
                           & "'");

                        Put ("Reduce to ");
                        Print_Reduce (Save);
                     end if;
                  end;
               end if;
            end if;
         end loop;
      end loop;
   end Print_Conflicts;

end Gela.Grammars_Debug;
