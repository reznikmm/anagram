package body Attribute_Grammars.Example is

   Ex : Attribute_Grammar;

   procedure Create (Ex : out Attribute_Grammar) is
   begin
      Ex := new Attribute_Grammar_Node;
      Ex.Last_Nonterminal := 2;
      Ex.Nonterminals (1) := new Nonterminal_Node;
      Ex.Nonterminals (2) := new Nonterminal_Node;
      Ex.Nonterminals (1).Attributes (1) := new Attribute_Declaration_Node;

      Ex.Nonterminals (2).Attributes (1) := new Attribute_Declaration_Node;
      Ex.Nonterminals (2).Attributes (2) := new Attribute_Declaration_Node;
      Ex.Nonterminals (2).Attributes (3) := new Attribute_Declaration_Node;

      declare
         N : Nonterminal := Ex.Nonterminals (1);
      begin
         N.Index := 1;
         N.Last_Attribute := 1;
         N.Attributes (1).Index := 1;
         N.Attributes (1).Last_Name := 1;
         N.Attributes (1).Name (1 .. 1) := "r";
         N.Attributes (1).Is_Inherited := False;

         N.Last_Production := 1;
         declare
            P : Production := new Production_Node;
         begin
            P.Last_Rule := 2;
            P.Rules (1) := new Rule_Node;
            P.Rules (2) := new Rule_Node;

            P.Last_Part := 1;
            P.Parts (1) := new Part_Node;
            P.Parts (1).Index := 1;
            P.Parts (1).Parent := P;
            P.Parts (1).Reference := Ex.Nonterminals (2);
            P.Parts (1).Last_Name := 1;
            P.Parts (1).Name (1 .. 1) := "E";

            declare
               R : Rule := P.Rules (1);
            begin
               R.Result := new Attribute_Node;

               R.Result.Declaration := Ex.Nonterminals (2).Attributes (2);
               R.Result.Origin := P.Parts (1);

               R.Last_Parameter := 1;
               R.Parameters (1) := new Attribute_Node;

               R.Parameters (1).Declaration :=
                 Ex.Nonterminals (2).Attributes (1);

               R.Parameters (1).Origin := P.Parts (1);
            end;

            declare
               R : Rule := P.Rules (2);
            begin
               R.Result := new Attribute_Node;

               R.Result.Declaration := N.Attributes (1);
               R.Result.Origin := null;

               R.Last_Parameter := 1;
               R.Parameters (1) := new Attribute_Node;

               R.Parameters (1).Declaration :=
                 Ex.Nonterminals (2).Attributes (3);

               R.Parameters (1).Origin := P.Parts (1);
            end;

            P.Parent := N;
            N.Productions (1) := P;
         end;

         N.Last_Name := 1;
         N.Name (1 .. 1) := "S";
      end;



      declare
         N : Nonterminal := Ex.Nonterminals (2);
      begin
         N.Index := 2;
         N.Last_Attribute := 3;

         N.Attributes (1).Index := 1;
         N.Attributes (1).Last_Name := 1;
         N.Attributes (1).Name (1 .. 1) := "s";
         N.Attributes (1).Is_Inherited := False;
         N.Attributes (2).Index := 2;
         N.Attributes (2).Last_Name := 1;
         N.Attributes (2).Name (1 .. 1) := "i";
         N.Attributes (2).Is_Inherited := True;
         N.Attributes (3).Index := 3;
         N.Attributes (3).Last_Name := 1;
         N.Attributes (3).Name (1 .. 1) := "t";
         N.Attributes (3).Is_Inherited := False;

         N.Last_Name := 1;
         N.Name (1 .. 1) := "E";

         N.Last_Production := 2;
         N.Productions (1) := new Production_Node;
         N.Productions (2) := new Production_Node;

         declare
            P : Production := N.Productions (1);
         begin
            P.Last_Rule := 4;
            P.Rules (1) := new Rule_Node;
            P.Rules (2) := new Rule_Node;
            P.Rules (3) := new Rule_Node;
            P.Rules (4) := new Rule_Node;

            P.Last_Part := 2;
            P.Parts (1) := new Part_Node;
            P.Parts (2) := new Part_Node;
            P.Parts (1).Index := 1;
            P.Parts (1).Parent := P;
            P.Parts (1).Reference := Ex.Nonterminals (2);
            P.Parts (1).Last_Name := 2;
            P.Parts (1).Name (1 .. 2) := "E1";
            P.Parts (2).Index := 2;
            P.Parts (2).Parent := P;
            P.Parts (2).Reference := Ex.Nonterminals (2);
            P.Parts (2).Last_Name := 2;
            P.Parts (2).Name (1 .. 2) := "E2";

            declare
               R : Rule := P.Rules (1);
            begin
               R.Result := new Attribute_Node;

               R.Result.Declaration := N.Attributes (1);
               R.Result.Origin := null;

               R.Last_Parameter := 2;
               R.Parameters (1) := new Attribute_Node;
               R.Parameters (2) := new Attribute_Node;

               R.Parameters (1).Declaration := N.Attributes (1);
               R.Parameters (1).Origin := P.Parts (1);

               R.Parameters (2).Declaration := N.Attributes (1);
               R.Parameters (2).Origin := P.Parts (2);
            end;

            declare
               R : Rule := P.Rules (2);
            begin
               R.Result := new Attribute_Node;

               R.Result.Declaration := N.Attributes (2);
               R.Result.Origin := P.Parts (1);

               R.Last_Parameter := 1;
               R.Parameters (1) := new Attribute_Node;

               R.Parameters (1).Declaration := N.Attributes (2);
               R.Parameters (1).Origin := null;
            end;

            declare
               R : Rule := P.Rules (3);
            begin
               R.Result := new Attribute_Node;

               R.Result.Declaration := N.Attributes (2);
               R.Result.Origin := P.Parts (2);

               R.Last_Parameter := 1;
               R.Parameters (1) := new Attribute_Node;

               R.Parameters (1).Declaration := N.Attributes (2);
               R.Parameters (1).Origin := null;
            end;

            declare
               R : Rule := P.Rules (4);
            begin
               R.Result := new Attribute_Node;

               R.Result.Declaration := N.Attributes (3);
               R.Result.Origin := null;

               R.Last_Parameter := 2;
               R.Parameters (1) := new Attribute_Node;
               R.Parameters (2) := new Attribute_Node;

               R.Parameters (1).Declaration := N.Attributes (3);
               R.Parameters (1).Origin := P.Parts (1);

               R.Parameters (2).Declaration := N.Attributes (3);
               R.Parameters (2).Origin := P.Parts (2);
            end;

            P.Parent := N;
         end;


         declare
            P : Production := N.Productions (2);
         begin
            P.Last_Rule := 2;
            P.Rules (1) := new Rule_Node;
            P.Rules (2) := new Rule_Node;

            P.Last_Part := 0;

            declare
               R : Rule := P.Rules (1);
            begin
               R.Result := new Attribute_Node;

               R.Result.Declaration := N.Attributes (1);
               R.Result.Origin := null;

               R.Last_Parameter := 0;
            end;

            declare
               R : Rule := P.Rules (2);
            begin
               R.Result := new Attribute_Node;

               R.Result.Declaration := N.Attributes (3);
               R.Result.Origin := null;

               R.Last_Parameter := 1;
               R.Parameters (1) := new Attribute_Node;

               R.Parameters (1).Declaration := N.Attributes (2);
               R.Parameters (1).Origin := null;
            end;

            P.Parent := N;
         end;

      end;


   end Create;


   -------
   -- X --
   -------

   function X return Attribute_Grammar is
   begin
      if Ex = null then
         Create (Ex);
      end if;

      return Ex;
   end X;

end Attribute_Grammars.Example;
