%token Equal_Token --  '::='
%token Inherited_Token
%token Synthesized_Token
%token Attributes_Token
%token Rules_Token
%token Identifier_Token
%token Token_Token
%token Open_Rule_Token
%token Rule_Body_Token
%token Close_Rule_Token
%token For_Token
%token Regexp_Token

{
  type YYSType is new Integer;
}

%%
input_file : item_list;

item_list : item |
  item_list item
;

item : 
 token_rule
 syntax_rule |
 inherited_attributes |
 synthesized_attributes |
 rules
;

token_rule:
Token_Token identifier;

syntax_rule :
identifier Equal_Token production_list ';' |
;

production_list : production |
 named_production_list;

named_production_list : named_production |
 named_production_list named_production
;

named_production :
'(' identifier ')' production;

production : named_part |
 production named_part
;

named_part : part |
part '<' identifier '>';

part : identifier |
 '{' production_list '}' |
 '[' production_list ']';

inherited_attributes :
 Inherited_Token Attributes_Token attribute_list
;

synthesized_attributes :
 Synthesized_Token Attributes_Token attribute_list
;

attribute_list : attribute |
  attribute_list attribute
;

attribute :
  regexp_list ':' identifier_list ';'
;

regexp_list : regexp | regexp_list regexp;

regexp : identifier | Regexp_Token;

identifier_list : identifier |
  identifier_list ',' identifier
;

rules : Rules_Token For_Token regexp_list ':'
 Open_Rule_Token Rule_Body_Token Close_Rule_Token;

identifier : Identifier_Token;


%%
-- 1
with League.Strings;

##

   type Parser is tagged limited private;

   procedure Read
     (Self : in out Parser;
     Text : League.Strings.Universal_String);

private

   type Parser is tagged limited null record;

-- 2
##
with Ada.Wide_Wide_Text_Io;
with String_Sources;
with Gela.Grammars.Scanners;
with Gela.Grammars.Scanner_Handler;
-- 3
##
   procedure Read
     (Self : in out Parser;
      Text : League.Strings.Universal_String)
   is
      Scanner  : aliased Gela.Grammars.Scanners.Scanner;
      Handler  : aliased Gela.Grammars.Scanner_Handler.Handler;

      procedure yyerror (X : Wide_Wide_String) is
      begin
        Ada.Wide_Wide_Text_IO.Put_Line
          (X & " on line");  --  & Positive'Wide_Wide_Image (Handler.Get_Line));
      end;

      function YYLex return Token is
         Result : Token;
      begin
         Scanner.Get_Token (Result);
         return Result;
      end YYLex;

##

      Source   : aliased String_Sources.String_Source;
   begin
      Source.Create (Text);
      Scanner.Set_Source (Source'Unchecked_Access);
      Scanner.Set_Handler (Handler'Unchecked_Access);
      YYParse;
   end Read;
