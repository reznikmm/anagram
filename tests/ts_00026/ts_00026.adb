--  Check EBNF expansion for [a [b] [c]]

with Anagram.Grammars_Convertors;
with Anagram.Grammars.Reader;
with Anagram.Grammars_Debug;

procedure TS_00026 is
   G : constant Anagram.Grammars.Grammar :=
     Anagram.Grammars.Reader.Read ("test.ag");
   Plain    : constant Anagram.Grammars.Grammar :=
     Anagram.Grammars_Convertors.Convert (G, Left => False);
begin
   Anagram.Grammars_Debug.Print (Plain);
end TS_00026;
