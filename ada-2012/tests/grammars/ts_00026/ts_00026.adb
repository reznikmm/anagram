--  Check EBNF expansion for [a [b] [c]]

with Gela.Grammars_Convertors;
with Gela.Grammars.Reader;
with Gela.Grammars_Debug;

procedure TS_00026 is
   G : constant Gela.Grammars.Grammar :=
     Gela.Grammars.Reader.Read ("test.ag");
   Plain    : constant Gela.Grammars.Grammar :=
     Gela.Grammars_Convertors.Convert (G, Left => False);
begin
   Gela.Grammars_Debug.Print (Plain);
end TS_00026;
