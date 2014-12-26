%token Equal_Token --  '::='
%token Inherited_Token
%token Synthesized_Token
%token Attributes_Token
%token Rules_Token
%token Priority_Token
%token Identifier_Token
%token Integer_Token
%token Token_Token
%token Open_Rule_Token
%token Rule_Body_Token
%token Close_Rule_Token
%token For_Token
%token With_Token
%token Regexp_Token

%with League.Strings;
%with League.String_Vectors;
%with Ada.Containers.Vectors;
%with Ada.Containers.Ordered_Maps;
%with Gela.Grammars.Parser_Utils;
{
   package PU renames Gela.Grammars.Parser_Utils;

   type Value_Kinds is
     (None, Image, Vector,
      Part, Named_Part, Production, Named_Production, Production_List);

   type YYSType (Kind : Value_Kinds := None) is record
      case Kind is
         when None =>
            null;
         when Image =>
            Image  : League.Strings.Universal_String;
         when Vector =>
            Vector : League.String_Vectors.Universal_String_Vector;
         when Named_Part =>
            Named_Part : PU.Named_Part;
         when Part =>
            Part : PU.Part_Access;
         when Production =>
            Production : PU.Production_Access;
         when Named_Production =>
            Named_Production : PU.Named_Production;
         when Production_List =>
            Production_List : PU.Production_List_Access;
      end case;
   end record;

}

%%
input_file : item_list;

item_list : item |
  item_list item
;

item :
 token_rule |
 with_rule |
 syntax_rule |
 inherited_attributes |
 synthesized_attributes |
 priority |
 rules
;

token_rule: Token_Token identifier ';'
  { Context.Add_Token ($2.Image); }

| Token_Token identifier Priority_Token integer identifier  ';'
  { Context.Add_Token ($2.Image, $4.Image, $5.Image); }
;

with_rule : With_Token identifier ';'
  { Context.Add_With ($2.Image); }
;

syntax_rule : identifier Equal_Token production_list ';'
{
  Context.Add_Non_Terminal ($1.Image, $3.Production_List);
}
;

production_list : named_production
{
 $$ := (Production_List,
        Context.New_Production_List ($1.Named_Production));
}

| production_list '|' named_production
{
 $$ := (Production_List,
        Context.Add_Production ($1.Production_List, $3.Named_Production));
}
;

named_production : '(' identifier ')' production
{
  $$ := (Named_Production,
         Context.To_Named_Production ($4.Production, $2.Image));
}

| production
{
  $$ := (Named_Production,
         Context.To_Named_Production ($1.Production));
}
;

production : named_part
{ $$ := (Production, Context.New_Production ($1.Named_Part));}

| production named_part
{ $$ := (Production, Context.Add_Part ($1.Production, $2.Named_Part));}
;

named_part : part
{ $$ := (Named_Part, Context.To_Named_Part ($1.Part)); }

| part '<' identifier '>'
{ $$ := (Named_Part, Context.To_Named_Part ($1.Part, $3.Image)); }
;

part : identifier
{ $$ := (Part, Context.Add_Reference ($1.Image)); }

 | '{' production_list '}'
{ $$ := (Part, Context.Add_List ($2.Production_List)); }

 | '[' production_list ']'
{ $$ := (Part, Context.Add_Option ( $2.Production_List)); }
;

inherited_attributes :
 Inherited_Token Attributes_Token inherited_attribute
;

synthesized_attributes :
 Synthesized_Token Attributes_Token synthesized_attribute
;

inherited_attribute :
  identifier_list ':' attr_type ':' identifier_list ';'
{
  $$ := (Kind => None);
  Context.Add_Inherited_Attr
   (Target => $1.Vector,
    Tipe   => $3.Image,
    Names  => $5.Vector);
}
;

synthesized_attribute :
  identifier_list ':' attr_type ':' identifier_list ';'
{
  $$ := (Kind => None);
  Context.Add_Synthesized_Attr
   (Target => $1.Vector,
    Tipe   => $3.Image,
    Names  => $5.Vector);
}
;

attr_type : identifier;

rules : Rules_Token Identifier_Token identifier_list ':'
 Open_Rule_Token rule_body Close_Rule_Token
{
  $$ := (Kind => None);
  Context.Add_Rule ($3.Vector, $6.Image);
}
;

rule_body : Rule_Body_Token
  { $$ := (Image, Scanner.Get_Text); }
;

priority : Priority_Token identifier integer identifier ';'
{
  Context.Add_Priority ($2.Image, $3.Image, $4.Image);
}
;

identifier_list : identifier
{
   $$ := (Vector, League.String_Vectors.Empty_Universal_String_Vector);
   $$.Vector.Append ($1.Image);
}

 | identifier_list ',' identifier
{
   $$ :=(Vector, $1.Vector);
   $$.Vector.Append ($3.Image);
}
;

identifier : Identifier_Token
  { $$ := (Image, Scanner.Get_Text); }
;

integer : Integer_Token
  { $$ := (Image, Scanner.Get_Text); }
;


%%
-- 1
with League.Strings;
with Gela.Grammars.Constructors;

##

   type Parser is tagged limited private;

   procedure Read
     (Self : in out Parser;
      Text : League.Strings.Universal_String;
      Tail_List : Boolean := False);

   function Grammar (Self : in out Parser) return Gela.Grammars.Grammar;

private

   type Parser is tagged limited record
      Constructor : Gela.Grammars.Constructors.Constructor;
   end record;
-- 2
##
with Ada.Wide_Wide_Text_Io;
with String_Sources;
with Gela.Grammars.Scanners;
with Gela.Grammars.Scanner_Handler;
with League.String_Vectors;
with Gela.Grammars.Parser_Utils;
-- 3
##
   function Grammar (Self : in out Parser) return Gela.Grammars.Grammar is
   begin
      return Gela.Grammars.Constructors.Complete (Self.Constructor);
   end Grammar;

   procedure Read
     (Self : in out Parser;
      Text : League.Strings.Universal_String;
      Tail_List : Boolean := False)
   is
      Scanner     : aliased Gela.Grammars.Scanners.Scanner;
      Handler     : aliased Gela.Grammars.Scanner_Handler.Handler;
      Context     : PU.Context_Node;

      procedure yyerror (X : Wide_Wide_String) is
      begin
        Ada.Wide_Wide_Text_IO.Put_Line
          (X & " on line" & Positive'Wide_Wide_Image (Handler.Get_Line));
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
      Context.Complete (Self.Constructor, Tail_List);
   end Read;
