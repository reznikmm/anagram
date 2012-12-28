--  Check extended attributed grammar reader

with Gela.Grammars.Reader;
with Gela.Grammars_Debug;

procedure Main is
   G : aliased Gela.Grammars.Grammar :=
     Gela.Grammars.Reader.Read ("test.ag");
begin
   Gela.Grammars_Debug.Print (G);
end Main;
