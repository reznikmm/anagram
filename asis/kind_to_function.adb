with Text_Streams.File;
with XML_IO.Stream_Readers;
with Ada.Containers.Ordered_Maps;
with Ada.Strings.Unbounded;
with Ada.Strings.Maps;
with Ada.Text_IO;

package body Kind_To_Function is

   use Ada.Strings.Unbounded;

   package Maps is new Ada.Containers.Ordered_Maps
     (Unbounded_String, Unbounded_String);

   Map : Maps.Map;

   Separator : Ada.Strings.Maps.Character_Set;

   procedure Add (Kind, Func : String) is
   begin
      Map.Insert (To_Unbounded_String (Kind), To_Unbounded_String (Func));
   exception when others =>
      Ada.Text_IO.Put_Line ("dublicate: " & Kind);
      raise;
   end Add;

   procedure Initialize is
      use XML_IO;
      use Ada.Strings.Maps;
      package R renames XML_IO.Stream_Readers;

      Stream   : aliased Text_Streams.File.File_Text_Stream;
      Parser   : R.Reader (Stream'Access, R.Default_Buffer_Size);
   begin
      Text_Streams.File.Open (Stream, "func.xml");
      R.Initialize (Parser);

      while R.More_Pieces (Parser) loop
         case R.Piece_Kind (Parser) is
            when Start_Element =>
               if R.Name (Parser) = "item" then
                  Add (R.Attribute_Value
                         (Parser, "name", Raise_Error => True),
                       R.Attribute_Value
                         (Parser, "func", Raise_Error => True));
                  null;
               end if;
            when others =>
               null;
         end case;

         R.Next (Parser);
      end loop;

      Separator := To_Set (Sequence => ",|. ");

   end Initialize;

   function Get (Kind : String) return String is
      X : Unbounded_String := To_Unbounded_String (Kind);
   begin
      if Index (X, Separator) > 0 then
         X := To_Unbounded_String (Slice (X, 1, Index (X, Separator) - 1));
      end if;
      return To_String (Map.Element (X));
   exception when others =>
      Ada.Text_IO.Put_Line ("not found: " & Kind);
      raise;
   end Get;

end Kind_To_Function;
