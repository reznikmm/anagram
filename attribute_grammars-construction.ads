package Attribute_Grammars.Construction is

   function Create return Attribute_Grammar;

   procedure Create
     (Object     : in     Attribute_Grammar;
      Name       : in     String;
      Type_Name  : in     String;
      Expression : in     String;
      Result     :    out Nonterminal);

   procedure Create
     (Object  : in     Nonterminal;
      Kind    : in     String;
      Result  :    out Production);

   procedure  Create
     (Object    : in     Nonterminal;
      Name      : in     String;
      Type_Name : in     String;
      Result    :    out Attribute_Declaration);

   procedure Create
     (Object  : in     Production;
      Name    : in     String;
      Result  :    out Part);

   procedure Create
     (Object  : in     Production;
      Result  :    out Rule);

   procedure Create_Result
     (Object  : in     Rule;
      Result  :    out Attribute);

   procedure Create_Result
     (Object  : in     Rule;
      Result  :    out Attribute;
      Origin  : in     Part);

   procedure Create_Argument
     (Object  : in     Rule;
      Result  :    out Attribute);

   procedure Create_Argument
     (Object  : in     Rule;
      Result  :    out Attribute;
      Origin  : in     Part);

   procedure Set_Text
     (Object  : in     Rule;
      Text    : in     String);

   procedure Set_Reference
     (Object  : in     Part;
      NT      : in     Nonterminal);

   procedure Set_Declaration
     (Object  : in     Attribute;
      Decl    : in     Attribute_Declaration);

   procedure Set_Expression
     (Object     : in     Nonterminal;
      Expression : in     String);

   function Find
     (Object    : Production;
      Part_Name : String) return Part;

   function Find
     (Object  : Attribute_Grammar;
      NT_Name : String) return Nonterminal;

   function Find
     (Object    : Nonterminal;
      Attr_Name : String) return Attribute_Declaration;

   Not_Found : exception;

end Attribute_Grammars.Construction;
