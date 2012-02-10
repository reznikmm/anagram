------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Ada.Wide_Wide_Text_IO;

package body Gela.Grammars_Debug is

   procedure Print (Self : access Gela.Grammars.Grammar) is
      use Ada.Wide_Wide_Text_IO;
      use Gela.Grammars;
   begin
      Put_Line ("Terminals:");

      for J in 1 .. Self.Last_Terminal loop
         Put_Line (Terminal_Count'Wide_Wide_Image (J) & " " &
                     Self.Terminal (J).Image.To_Wide_Wide_String);
      end loop;

      Put_Line ("Non Terminals:");

      for J in 1 .. Self.Last_Non_Terminal loop
         Put_Line (Non_Terminal_Count'Wide_Wide_Image (J) & " " &
                     Self.Non_Terminal (J).Name.To_Wide_Wide_String);

         for P in Self.Non_Terminal (J).First .. Self.Non_Terminal (J).Last
         loop
            Put_Line ("  Production: " &
                        Self.Production (P).Name.To_Wide_Wide_String);

            for R in Self.Production (P).First .. Self.Production (P).Last loop
               Put ("    " & Self.Part (R).Name.To_Wide_Wide_String
                      & " refs ");

               if Self.Part (R).Is_Terminal_Reference then
                  Put_Line (Self.Terminal (Self.Part (R).Denote)
                              .Image.To_Wide_Wide_String);
               else
                  Put_Line (Self.Non_Terminal (Self.Part (R).Denote)
                              .Name.To_Wide_Wide_String);
               end if;
            end loop;
         end loop;
      end loop;
   end Print;

   procedure Print (Self : access Gela.Grammars.Extended.Grammar) is
      use Ada.Wide_Wide_Text_IO;
      use Gela.Grammars;

      procedure Print_Productions (First, Last : Production_Count);

      procedure Print_Productions (First, Last : Production_Count) is
      begin
         for P in First .. Last loop
            Put_Line ("  Production: " &
                        Self.Production (P).Name.To_Wide_Wide_String);

            for R in Self.Production (P).First .. Self.Production (P).Last loop
               Put ("    " & Self.Part (R).Name.To_Wide_Wide_String);

               if Self.Part (R).Is_Terminal_Reference then
                  Put_Line (" refs " & Self.Terminal (Self.Part (R).Denote)
                              .Image.To_Wide_Wide_String);
               elsif Self.Part (R).Is_Non_Terminal_Reference then
                  Put_Line (" refs " & Self.Non_Terminal (Self.Part (R).Denote)
                              .Name.To_Wide_Wide_String);
               else
                  if Self.Part (R).Is_List then
                     Put_Line (" List:");
                  else
                     Put_Line (" Option:");
                  end if;

                  Print_Productions (Self.Part (R).First, Self.Part (R).Last);

                  Put_Line ("    End");
               end if;
            end loop;
         end loop;
      end Print_Productions;
   begin
      Put_Line ("Terminals:");

      for J in 1 .. Self.Last_Terminal loop
         Put_Line (Terminal_Count'Wide_Wide_Image (J) & " " &
                     Self.Terminal (J).Image.To_Wide_Wide_String);
      end loop;

      Put_Line ("Non Terminals:");

      for J in 1 .. Self.Last_Non_Terminal loop
         Put_Line (Non_Terminal_Count'Wide_Wide_Image (J) & " " &
                     Self.Non_Terminal (J).Name.To_Wide_Wide_String);

         Print_Productions
           (Self.Non_Terminal (J).First, Self.Non_Terminal (J).Last);
      end loop;
   end Print;

   procedure Print (Self : access Gela.Grammars.Attributed.Grammar) is
      use Ada.Wide_Wide_Text_IO;
      use Gela.Grammars;
      use Gela.Grammars.Attributed;

      procedure Print_Attr (Attr : Attribute_Index);

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
   begin
      Put_Line ("Terminals:");

      for J in 1 .. Self.Last_Terminal loop
         Put_Line (Terminal_Count'Wide_Wide_Image (J) & " " &
                     Self.Terminal (J).Image.To_Wide_Wide_String);

         for D in Self.Terminal (J).First .. Self.Terminal (J).Last loop
            Put_Line
              ("  Attr: " & Self.Declaration (D).Name.To_Wide_Wide_String &
                 " inherited=" &
                 Boolean'Wide_Wide_Image (Self.Declaration (D).Is_Inherited));
         end loop;
      end loop;

      Put_Line ("Non Terminals:");

      for J in 1 .. Self.Last_Non_Terminal loop
         Put_Line (Non_Terminal_Count'Wide_Wide_Image (J) & " " &
                     Self.Non_Terminal (J).Name.To_Wide_Wide_String);

         for D in Attribute_Declaration_Count'(Self.Non_Terminal (J).First) ..
           Self.Non_Terminal (J).Last
         loop
            Put_Line
              ("  Attr: " & Self.Declaration (D).Name.To_Wide_Wide_String &
                 " inherited=" &
                 Boolean'Wide_Wide_Image (Self.Declaration (D).Is_Inherited));
         end loop;

         for P in Production_Count'(Self.Non_Terminal (J).First) ..
           Self.Non_Terminal (J).Last
         loop
            Put_Line ("  Production: " &
                        Self.Production (P).Name.To_Wide_Wide_String);

            for R in Part_Count'(Self.Production (P).First) ..
              Self.Production (P).Last
            loop
               Put ("    " & Self.Part (R).Name.To_Wide_Wide_String
                      & " refs ");

               if Self.Part (R).Is_Terminal_Reference then
                  Put_Line (Self.Terminal (Self.Part (R).Denote)
                              .Image.To_Wide_Wide_String);
               else
                  Put_Line (Self.Non_Terminal (Self.Part (R).Denote)
                              .Name.To_Wide_Wide_String);
               end if;
            end loop;

            for R in Rule_Count'(Self.Production (P).First) ..
              Self.Production (P).Last
            loop
               Put_Line ("Rule: ");
               Put ("  Result: ");
               Print_Attr (Self.Rule (R).Result);

               for A in Self.Rule (R).Argument_First ..
                 Self.Rule (R).Argument_Last
               loop
                  Put ("  Arg: ");
                  Print_Attr (A);
               end loop;
            end loop;
         end loop;
      end loop;
   end Print;

   -----------
   -- Print --
   -----------

   procedure Print (Self : access Gela.Grammars.Attributed.Extended.Grammar) is
      use Ada.Wide_Wide_Text_IO;
      use Gela.Grammars;
      use Gela.Grammars.Attributed;
      use Gela.Grammars.Attributed.Extended;

      procedure Print_Attr (Attr : Attribute_Index);
      procedure Print_Productions (First, Last : Production_Count);
      procedure Print_Declarations (First, Last : Attribute_Declaration_Count);

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
                        Self.Production (P).Name.To_Wide_Wide_String);

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
                  if Self.Part (R).Is_List then
                     Put_Line (" List:");
                     Print_Declarations
                       (Self.Part (R).First, Self.Part (R).Last);
                  else
                     Put_Line (" Option:");
                  end if;

                  Print_Productions (Self.Part (R).First, Self.Part (R).Last);

                  Put_Line ("    End");
               end if;
            end loop;

            for R in Rule_Count'(Self.Production (P).First) ..
              Self.Production (P).Last
            loop
               Put_Line ("Rule: ");
               Put ("  Result: ");
               Print_Attr (Self.Rule (R).Result);

               for A in Self.Rule (R).Argument_First ..
                 Self.Rule (R).Argument_Last
               loop
                  Put ("  Arg: ");
                  Print_Attr (A);
               end loop;
            end loop;
         end loop;
      end Print_Productions;

   begin
      Put_Line ("Terminals:");

      for J in 1 .. Self.Last_Terminal loop
         Put_Line (Terminal_Count'Wide_Wide_Image (J) & " " &
                     Self.Terminal (J).Image.To_Wide_Wide_String);

         Print_Declarations
           (Self.Terminal (J).First, Self.Terminal (J).Last);
      end loop;

      Put_Line ("Non Terminals:");

      for J in 1 .. Self.Last_Non_Terminal loop
         Put_Line (Non_Terminal_Count'Wide_Wide_Image (J) & " " &
                     Self.Non_Terminal (J).Name.To_Wide_Wide_String);

         Print_Declarations
           (Self.Non_Terminal (J).First, Self.Non_Terminal (J).Last);

         Print_Productions
           (Self.Non_Terminal (J).First, Self.Non_Terminal (J).Last);
      end loop;
   end Print;

end Gela.Grammars_Debug;
