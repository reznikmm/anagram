with Ada.Strings.Unbounded;

package Attribute_Grammars is

   type Attribute_Grammar     is private;
   type Nonterminal           is private;
   type Production            is private;
   type Attribute_Declaration is private;
   type Attribute             is private;
   type Part                  is private;
   type Rule                  is private;

   type Nonterminal_List is array (Positive range <>) of Nonterminal;
   type Production_List  is array (Positive range <>) of Production;
   type Attribute_List   is array (Positive range <>) of Attribute;
   type Part_List        is array (Positive range <>) of Part;
   type Rule_List        is array (Positive range <>) of Rule;

   type Attribute_Declaration_List is
     array (Positive range <>) of Attribute_Declaration;

   function Nonterminals (X : Attribute_Grammar) return Nonterminal_List;
   function Productions  (X : Nonterminal) return Production_List;
   function Attributes   (X : Nonterminal) return Attribute_Declaration_List;
   function Parts        (X : Production)  return Part_List;
   function Rules        (X : Production)  return Rule_List;
   function Result       (X : Rule) return Attribute;
   function Parameters   (X : Rule) return Attribute_List;

   function Name  (X : Nonterminal) return String;
   function Index (X : Nonterminal) return Positive;

   function Parent (X : Production) return Nonterminal;

   function Name      (X : Part) return String;
   function Parent    (X : Part) return Production;
   function Reference (X : Part) return Nonterminal;
   function Index     (X : Part) return Positive;

   function Parent    (X : Rule) return Production;

   function Name           (X : Attribute_Declaration) return String;
   function Is_Inherited   (X : Attribute_Declaration) return Boolean;
   function Is_Synthesized (X : Attribute_Declaration) return Boolean;
   function Index          (X : Attribute_Declaration) return Positive;

   function Declaration    (X : Attribute) return Attribute_Declaration;
   function Left_Hand_Side (X : Attribute) return Boolean;
   function Origin         (X : Attribute) return Part;
   function Parent         (X : Attribute) return Rule;
   function Index          (X : Attribute) return Positive;

   --  Counters
   function Productions  (X : Attribute_Grammar) return Natural;
   function Attributes   (X : Production) return Natural;
   function Attributes   (X : Nonterminal) return Natural;

   --  Generator specific
   function Type_Name       (X : Nonterminal) return String;
   function Type_Name       (X : Attribute_Declaration) return String;
   function Case_Expression (X : Nonterminal) return String;
   function Kind            (X : Production) return String;
   function Text            (X : Rule) return String;

private

   type Attribute_Grammar_Node;
   type Nonterminal_Node;
   type Production_Node;
   type Attribute_Declaration_Node;
   type Attribute_Node;
   type Part_Node;
   type Rule_Node;

   type Attribute_Grammar     is access all Attribute_Grammar_Node;
   type Nonterminal           is access all Nonterminal_Node;
   type Production            is access all Production_Node;
   type Attribute_Declaration is access all Attribute_Declaration_Node;
   type Attribute             is access all Attribute_Node;
   type Part                  is access all Part_Node;
   type Rule                  is access all Rule_Node;

   type Attribute_Grammar_Node is record
      Last_Nonterminal : Natural := 0;
      Nonterminals     : Nonterminal_List (1 .. 150);
   end record;

   type Nonterminal_Node is record
      Index           : Positive;
      Last_Production : Natural := 0;
      Productions     : Production_List (1 .. 50);
      Last_Attribute  : Natural := 0;
      Attributes      : Attribute_Declaration_List (1 .. 10);
      Name            : Ada.Strings.Unbounded.Unbounded_String;
      Type_Name       : Ada.Strings.Unbounded.Unbounded_String;
      Expression      : Ada.Strings.Unbounded.Unbounded_String;
      Partitions      : Natural := 0;
   end record;

   type Production_Node is record
      Last_Rule : Natural := 0;
      Rules     : Rule_List (1 .. 10);
      Last_Part : Natural := 0;
      Parts     : Part_List (1 .. 10);
      Parent    : Nonterminal;
      Kind      : Ada.Strings.Unbounded.Unbounded_String;
   end record;

   type Attribute_Declaration_Node is record
      Index        : Positive;
      Name         : Ada.Strings.Unbounded.Unbounded_String;
      Type_Name    : Ada.Strings.Unbounded.Unbounded_String;
      Is_Inherited : Boolean := True;
      Partition    : Natural := 0;
   end record;

   type Attribute_Node is record
      Declaration    : Attribute_Declaration;
      Origin         : Part;
      Parent         : Rule;
   end record;

   type Part_Node is record
      Parent    : Production;
      Reference : Nonterminal;
      Index     : Positive;
      Name      : Ada.Strings.Unbounded.Unbounded_String;
   end record;

   type Rule_Node is record
      Parent         : Production;
      Result         : Attribute;
      Last_Parameter : Natural := 0;
      Parameters     : Attribute_List (1 .. 10);
      Text           : Ada.Strings.Unbounded.Unbounded_String;
      Total_Order    : Natural := 0;
   end record;

end Attribute_Grammars;
