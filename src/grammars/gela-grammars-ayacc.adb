------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Ada.Wide_Wide_Text_IO;
with Gela.Grammars.Rule_Templates;
with League.String_Vectors;

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

      New_Line;
      Put_Line ("%start " & Input.Non_Terminal (Input.Root).Name);
      New_Line;
      Put_Line ("%%");
      New_Line;

      for NT of Input.Non_Terminal loop
         Put_Line (NT.Name & " :");

         for P in NT.First .. NT.Last loop
            declare
               Prod : Production renames Input.Production (P);
               Length : Positive := 4;
            begin
               if P = NT.First then
                  Put ("    ");
               else
                  Put ("   |");
               end if;

               for Part of Input.Part (Prod.First .. Prod.Last) loop
                  if Part.Is_Terminal_Reference then
                     Put (" " & Input.Terminal (Part.Denote).Image);
                     Length := Length + 1 +
                       Input.Terminal (Part.Denote).Image.Length;
                  else
                     Put (" " & Input.Non_Terminal (Part.Denote).Name);
                     Length := Length + 1 +
                       Input.Non_Terminal (Part.Denote).Name.Length;
                  end if;

                  if Length > 60 then
                     New_Line;
                     Put ("    ");
                     Length := 4;
                  end if;
               end loop;

               New_Line;

               for Rule of Input.Rule (Prod.First_Rule .. Prod.Last_Rule) loop
                  Put ("{");

                  declare
                     use Gela.Grammars.Rule_Templates;
                     Template : constant Rule_Template := Create (Rule.Text);
                     Values   : League.String_Vectors.Universal_String_Vector;
                     Name     : League.Strings.Universal_String;
                     Index    : Positive;
                  begin
                     for K in 1 .. Template.Count loop
                        if Template.Part_Name (K) = NT.Name then
                           Name := League.Strings.To_Universal_String ("$$");
                        else
                           Index := 1;
                           Name := League.Strings.To_Universal_String ("$err");

                           for Part of Input.Part (Prod.First .. Prod.Last)
                           loop
                              if Template.Part_Name (K) = Part.Name then
                                 declare
                                    Image : Wide_Wide_String :=
                                      Positive'Wide_Wide_Image (Index);
                                 begin
                                    Image (1) := '$';
                                    Name := League.Strings.To_Universal_String
                                      (Image);
                                    exit;
                                 end;
                              end if;

                              Index := Index + 1;
                           end loop;

                        end if;
                        Values.Append (Name);
                     end loop;

                     Put (Template.Substitute (Values));
                  end;

                  Put_Line ("}");
               end loop;
            end;
         end loop;

         Put_Line (";");
         New_Line;
      end loop;

      Put_Line ("%%");
   end Write;

end Gela.Grammars.AYACC;
