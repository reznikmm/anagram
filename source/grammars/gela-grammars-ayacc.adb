------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Ada.Wide_Wide_Text_IO;

package body Gela.Grammars.AYACC is

   use Ada.Wide_Wide_Text_IO;

   procedure Put (Text : League.Strings.Universal_String);
   procedure Put_Line (Text : League.Strings.Universal_String);

   ---------
   -- Put --
   ---------

   procedure Put (Text : League.Strings.Universal_String) is
   begin
      Put (Text.To_Wide_Wide_String);
   end Put;

   --------------
   -- Put_Line --
   --------------

   procedure Put_Line (Text : League.Strings.Universal_String) is
   begin
      Put_Line (Text.To_Wide_Wide_String);
   end Put_Line;

   -----------
   -- Write --
   -----------

   procedure Write (Input : Grammar) is
      use type League.Strings.Universal_String;
   begin
      for T of Input.Terminal loop
         Put_Line ("%token " & T.Image);
      end loop;

      Put_Line ("%%");
      New_Line;

      for NT of Input.Non_Terminal loop
         Put_Line (NT.Name & " :");

         for P in NT.First .. NT.Last loop
            declare
               Prod : Production renames Input.Production (P);
            begin
               for Part of Input.Part (Prod.First .. Prod.Last) loop
                  if Part.Is_Terminal_Reference then
                     Put (" " & Input.Terminal (Part.Denote).Image);
                  else
                     Put (" " & Input.Non_Terminal (Part.Denote).Name);
                  end if;
               end loop;

               if P = NT.Last then
                  Put_Line (";");
               else
                  Put_Line (" |");
               end if;
            end;
         end loop;

         New_Line;
      end loop;

      Put_Line ("%%");
   end Write;

end Gela.Grammars.AYACC;
