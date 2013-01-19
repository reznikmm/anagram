--  Check left recursion detection

with Ada.Text_IO;

with Gela.Grammars.Reader;
with Gela.Grammars_Recursive_Descent;
with Gela.Grammars_Convertors;

procedure Main is
   G : constant Gela.Grammars.Grammar := Gela.Grammars.Reader.Read ("test.ag");

   Plain : constant Gela.Grammars.Grammar :=
     Gela.Grammars_Convertors.Convert (G, Left => False);

   Ok : Boolean;
begin
   Gela.Grammars_Recursive_Descent.Generate (Plain, "-", Ok);
   Ada.Text_IO.Put_Line (Boolean'Image (Ok));
end Main;
