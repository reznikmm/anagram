--  Check extended attributed grammar reader

with Gela.Grammars.Reader;
with Gela.Grammars_Debug;

procedure TS_00007 is
   G : constant Gela.Grammars.Grammar :=
     Gela.Grammars.Reader.Read ("test.ag");
begin
   Gela.Grammars_Debug.Print (G);
end TS_00007;
