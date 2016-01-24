with  League.Strings;
with  League.String_Vectors;
with  Ada.Containers.Vectors;
with  Ada.Containers.Ordered_Maps;
with  Gela.Grammars.Parser_Utils;
package Ag_Tokens is


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


    YYLVal, YYVal : YYSType; 
    type Token is
        (End_Of_Input, Error, Equal_Token, Inherited_Token,
         Synthesized_Token, Local_Token, Attributes_Token,
         Rules_Token, Priority_Token, Identifier_Token,
         Integer_Token, Token_Token, Open_Rule_Token,
         Rule_Body_Token, Close_Rule_Token, For_Token,
         With_Token, Regexp_Token, ';',
         '|', '(', ')',
         '<', '>', '{',
         '}', '[', ']',
         ':', ',' );

    Syntax_Error : exception;

end Ag_Tokens;
