------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Ada.Containers.Generic_Anonymous_Array_Sort;
with Ada.Wide_Wide_Text_IO;
with Gela.Grammars.Rule_Templates;
with League.String_Vectors;

package body Gela.Grammars.AYACC is

   use Ada.Wide_Wide_Text_IO;

   procedure Put (Text : League.Strings.Universal_String);
   procedure Put_Line (Text : League.Strings.Universal_String);
   procedure Write_Tokens (Input : Grammar);
   function Image (Value : Precedence_Level) return Wide_Wide_String;

   -----------
   -- Image --
   -----------

   function Image (Value : Precedence_Level) return Wide_Wide_String is
      Text : constant Wide_Wide_String :=
        Precedence_Level'Wide_Wide_Image (Value);
   begin
      return "Prio_" & Text (2 .. Text'Last);
   end Image;

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
      Write_Tokens (Input);

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

               if Prod.Precedence.Associative /= Undefined then
                  Put ("%prec ");
                  Put_Line (Image (Prod.Precedence.Level));
               end if;

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

   ------------------
   -- Write_Tokens --
   ------------------

   procedure Write_Tokens (Input : Grammar) is
      use type League.Strings.Universal_String;
      Index : array (Input.Terminal'Range) of Terminal_Index;
      Prio : Precedence_Level := 0;

      function Less (Left, Right : Terminal_Index) return Boolean;
      procedure Swap (Left, Right : Terminal_Index);
      procedure Write_Prio (Prefix : Wide_Wide_String; T : Terminal);

      ----------
      -- Less --
      ----------

      function Less (Left, Right : Terminal_Index) return Boolean is
         L : Terminal renames Input.Terminal (Index (Left));
         R : Terminal renames Input.Terminal (Index (Right));
         L_Prio : Precedence_Level;
         R_Prio : Precedence_Level;
      begin
         if L.Precedence.Associative = Undefined then
            L_Prio := 0;
         else
            L_Prio := L.Precedence.Level;
         end if;

         if R.Precedence.Associative = Undefined then
            R_Prio := 0;
         else
            R_Prio := R.Precedence.Level;
         end if;

         return L_Prio < R_Prio or (L_Prio = R_Prio and L.Index < R.Index);
      end Less;

      ----------
      -- Swap --
      ----------

      procedure Swap (Left, Right : Terminal_Index) is
         Temp : constant Terminal_Index := Index (Left);
      begin
         Index (Left) := Index (Right);
         Index (Right) := Temp;
      end Swap;

      ----------------
      -- Write_Prio --
      ----------------

      procedure Write_Prio (Prefix : Wide_Wide_String; T : Terminal) is
      begin
         if Prio = T.Precedence.Level then
            Put (" ");
         elsif Prio = 0 then
            Put (Prefix);
            Put (Image (T.Precedence.Level));
            Put (" ");
         else
            New_Line;
            Put (Prefix);
            Put (Image (T.Precedence.Level));
            Put (" ");
         end if;
         Put (T.Image);
         Prio := T.Precedence.Level;
      end Write_Prio;

      procedure Sort is new Ada.Containers.Generic_Anonymous_Array_Sort
        (Index_Type => Terminal_Index,
         Less       => Less,
         Swap       => Swap);

   begin
      for T in Index'Range loop
         Index (T) := T;
      end loop;

      Sort (Index'First, Index'Last);

      for J in Index'Range loop
         declare
            T : Terminal renames Input.Terminal (Index (J));
         begin
            case T.Precedence.Associative is
               when Undefined =>
                  Put_Line ("%token " & T.Image);
               when None =>
                  Write_Prio ("%nonassoc ", T);

               when Left =>
                  Write_Prio ("%left ", T);

               when Right =>
                  Write_Prio ("%right ", T);
            end case;
         end;
      end loop;

      if Prio /= 0 then
         New_Line;
      end if;
   end Write_Tokens;

end Gela.Grammars.AYACC;
