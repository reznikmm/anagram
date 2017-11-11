--  Check extended attributed grammar reader

with Anagram.Grammars.Reader;
with Anagram.Grammars_Debug;

procedure TS_00007 is
   G : constant Anagram.Grammars.Grammar :=
     Anagram.Grammars.Reader.Read ("test.ag");
begin
   Anagram.Grammars_Debug.Print (G);
end TS_00007;
