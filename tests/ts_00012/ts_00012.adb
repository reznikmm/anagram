--  Check left recursion detection

with Ada.Text_IO;

with Anagram.Grammars.Reader;
with Anagram.Grammars_Recursive_Descent;
with Anagram.Grammars_Convertors;

procedure TS_00012 is
   G : constant Anagram.Grammars.Grammar :=
     Anagram.Grammars.Reader.Read ("test.ag");

   Plain : constant Anagram.Grammars.Grammar :=
     Anagram.Grammars_Convertors.Convert (G, Left => False);

   Ok : Boolean;
begin
   Anagram.Grammars_Recursive_Descent.Generate (Plain, "-", Ok);
   Ada.Text_IO.Put_Line (Boolean'Image (Ok));
end TS_00012;
