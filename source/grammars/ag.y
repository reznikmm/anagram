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
%token With_Token
%token Regexp_Token

%with League.Strings;
%with League.String_Vectors;
%with Ada.Containers.Vectors;
%with Ada.Containers.Ordered_Maps;
%with Gela.Grammars.Parser_Utils;
{
   use Gela.Grammars.Parser_Utils;

   type Value_Kinds is
     (None, Image, Vector, Attr_Def, Attr_Def_List,
      Part, Production, Production_List);

   type YYSType (Kind : Value_Kinds := None) is record
      case Kind is
         when None =>
            null;
         when Image =>
            Image  : League.Strings.Universal_String;
         when Vector =>
            Vector : League.String_Vectors.Universal_String_Vector;
         when Attr_Def =>
            Attr_Def : Attribute_Definitions;
         when Attr_Def_List =>
            Attr_Def_List : Attribute_Definitions_Vectors.Vector;
         when Part =>
            Part : Part_Node;
         when Production =>
            Production : Production_Index;
         when Production_List =>
            Production_List : Production_Index_Vectors.Vector;
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
 rules
;

token_rule: Token_Token identifier ';'
  { Context.Add_Token ($2.Image); }
;

with_rule : With_Token identifier ';'
  { Context.Add_With ($2.Image); }
;

syntax_rule : identifier Equal_Token production_list ';'
{
  Context.Add_NT ($1.Image, $3.Production_List);
}
;

production_list : production
{
 $$ := (Production_List,
        Production_Index_Vectors.To_Vector ($1.Production, 1));
}

| named_production_list
{ $$ := $1; }
;

named_production_list : named_production
{
 $$ := (Production_List,
        Production_Index_Vectors.To_Vector ($1.Production, 1));
}

| named_production_list '|' named_production
{
  $$ := $1;
  Context.Add_Production ($$.Production_List, $3.Production);
}
;

named_production : '(' identifier ')' production
{
  $$ := $4;
  Context.Set_Name ($4.Production, $2.Image);
}
;

production : named_part
{
  $$ := (Production, Production => <>);
  Context.New_Production ($1.Part, $$.Production);
}

| production named_part
{ $$ := $1; Context.Add_Part ($$.Production, $2.Part);}
;

named_part : part
{ $$ := $1; }

| part '<' identifier '>'
{ $$ := $1; $$.Part.Name := $3.Image; }
;

part : identifier
{ $$ := (Part, (Reference, Name => $1.Image, Reference => $1.Image)); }

 | '{' production_list '}'
{ $$ := (Part, (List, Name => <>, Nested => $2.Production_List)); }

 | '[' production_list ']'
{ $$ := (Part, (Option, Name => <>, Nested => $2.Production_List)); }
;

inherited_attributes :
 Inherited_Token Attributes_Token attribute_list
 {
   Context.Inherited.Append ($3.Attr_Def_List);
   $$ := (Kind => None);
 }
;

synthesized_attributes :
 Synthesized_Token Attributes_Token attribute_list
 {
   Context.Synthesized.Append ($3.Attr_Def_List);
   $$ := (Kind => None);
 }
;

attribute_list : attribute
{
 $$ := (Attr_Def_List,
        Attribute_Definitions_Vectors.To_Vector ($1.Attr_Def, 1));
}
;

attribute :
  regexp_list ':' attr_type ':' identifier_list ';'
  { $$ := (Attr_Def, ($1.Vector, $5.Vector, $3.Image)); }
;

attr_type : identifier;

rules : Rules_Token For_Token regexp_list ':'
 Open_Rule_Token rule_body Close_Rule_Token

{
   Context.Rules.Append (($3.Vector, $6.Image));
   $$ := (Kind => None);
}
;

rule_body : Rule_Body_Token
  { $$ := (Image, Scanner.Get_Text); }
;

regexp_list : regexp
{
   $$ := (Vector, League.String_Vectors.Empty_Universal_String_Vector);
   $$.Vector.Append ($1.Image);
}

| regexp_list regexp
{
   $$ :=(Vector, $1.Vector);
   $$.Vector.Append ($2.Image);
}
;

regexp : identifier
  { $$ := $1; }

 | Regexp_Token
  { $$ := (Image, Scanner.Get_Text); }
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


%%
-- 1
with League.Strings;
with Gela.Grammars.Attributed.Extended.Constructors;

##

   type Parser is tagged limited private;

   procedure Read
     (Self : in out Parser;
      Text : League.Strings.Universal_String);

   function Grammar
     (Self : Parser)
      return Gela.Grammars.Attributed.Extended.Grammar;

private

   type Parser is tagged limited record
      Constructor : Gela.Grammars.Attributed.Extended.Constructors.Constructor;
   end record;
-- 2
##
with Ada.Wide_Wide_Text_Io;
with String_Sources;
with Gela.Grammars.Scanners;
with Gela.Grammars.Scanner_Handler;
with League.String_Vectors;
with Gela.Grammars.Parser_Utils; use Gela.Grammars.Parser_Utils;
-- 3
##
   function Grammar
     (Self : Parser)
      return Gela.Grammars.Attributed.Extended.Grammar is
   begin
      return Gela.Grammars.Attributed.Extended.Constructors.Complete
        (Self.Constructor);
   end Grammar;

   procedure Complete
     (Self        : in out Parser;
      Prod_List   : Production_Vectors.Vector;
      Tokens      : League.String_Vectors.Universal_String_Vector;
      NT          : NT_Maps.Map;
      Start       : League.Strings.Universal_String;
      Inherited   : Attribute_Definitions_Vectors.Vector;
      Synthesized : Attribute_Definitions_Vectors.Vector;
      Rules       : Rule_Vectors.Vector;
      With_List   : League.String_Vectors.Universal_String_Vector) is separate;

   procedure Read
     (Self : in out Parser;
      Text : League.Strings.Universal_String)
   is
      use type Attribute_Definitions_Vectors.Vector;

      Scanner     : aliased Gela.Grammars.Scanners.Scanner;
      Handler     : aliased Gela.Grammars.Scanner_Handler.Handler;
      Context     : Context_Node;

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

      Complete
       (Self,
        Context.Prod_List,
        Context.Tokens,
        Context.NT,
        Context.Start,
        Context.Inherited,
        Context.Synthesized,
        Context.Rules,
        Context.With_List);
   end Read;
