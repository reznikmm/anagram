separate (Gela.Grammars.Scanners)
procedure On_Accept
  (Self    : not null access Gela.Grammars.Scanner_Handlers.Handler'Class;
   Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
   Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
   Token   : out Ag_Tokens.Token;
   Skip    : in out Boolean) is
begin
   case Rule is
      when 1 =>
         Self.Equal_Token (Scanner, Rule, Token, Skip);

      when 2 =>
         Self.Inherited_Token (Scanner, Rule, Token, Skip);

      when 3 =>
         Self.Synthesized_Token (Scanner, Rule, Token, Skip);

      when 4 =>
         Self.Attributes_Token (Scanner, Rule, Token, Skip);

      when 5 =>
         Self.Rules_Token (Scanner, Rule, Token, Skip);

      when 6 =>
         Self.Token_Token (Scanner, Rule, Token, Skip);

      when 7 =>
         Self.With_Token (Scanner, Rule, Token, Skip);

      when 8 =>
         Self.Priority_Token (Scanner, Rule, Token, Skip);

      when 9 =>
         Self.Integer_Token (Scanner, Rule, Token, Skip);

      when 10 =>
         Self.Identifier_Token (Scanner, Rule, Token, Skip);

      when 11 =>
         Self.Open_Rule_Token (Scanner, Rule, Token, Skip);

      when 12 =>
         Self.Rule_Body_Token (Scanner, Rule, Token, Skip);

      when 13 =>
         Self.Close_Rule_Token (Scanner, Rule, Token, Skip);

      when 14 =>
         Self.Semicolon_Token (Scanner, Rule, Token, Skip);

      when 15 =>
         Self.Open_Production_Name_Token (Scanner, Rule, Token, Skip);

      when 16 =>
         Self.Close_Production_Name_Token (Scanner, Rule, Token, Skip);

      when 17 =>
         Self.Open_Part_Name_Token (Scanner, Rule, Token, Skip);

      when 18 =>
         Self.Close_Part_Name_Token (Scanner, Rule, Token, Skip);

      when 19 =>
         Self.Open_List_Token (Scanner, Rule, Token, Skip);

      when 20 =>
         Self.Close_List_Token (Scanner, Rule, Token, Skip);

      when 21 =>
         Self.Open_Option_Token (Scanner, Rule, Token, Skip);

      when 22 =>
         Self.Close_Option_Token (Scanner, Rule, Token, Skip);

      when 23 =>
         Self.Colon_Token (Scanner, Rule, Token, Skip);

      when 24 =>
         Self.Or_Token (Scanner, Rule, Token, Skip);

      when 25 =>
         Self.Comma_Token (Scanner, Rule, Token, Skip);

      when 26 =>
         Self.Regexp_Token (Scanner, Rule, Token, Skip);

      when 27 =>
         Self.Spaces (Scanner, Rule, Token, Skip);

      when 28 =>
         Self.Comment (Scanner, Rule, Token, Skip);

      when 29 =>
         Self.New_Line (Scanner, Rule, Token, Skip);

      when others =>
         raise Constraint_Error;
   end case;
end On_Accept;
