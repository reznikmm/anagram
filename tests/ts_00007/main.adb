--  Check extended attributed grammar reader

with Gela.Grammars.Reader;
with Gela.Grammars_Debug;
with Gela.Grammars.Attributed.Extended;

procedure Main is
   G : aliased Gela.Grammars.Attributed.Extended.Grammar :=
     Gela.Grammars.Reader.Read ("test.ag");
begin
   Gela.Grammars_Debug.Print (G'Access);
end Main;
