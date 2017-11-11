with Anagram.Grammars;

package AST is

   type Node;

   type Node_Access is access all Node;

   type Node_Array is array (1 .. 4) of Node_Access;

   type Node is record
      Identifier     : Positive;
      Is_Token       : Boolean;
      Is_Alternative : Boolean;
      Children       : Node_Array;
      Count          : Positive;
      Prod           : Anagram.Grammars.Production_Index;
      NT             : Anagram.Grammars.Non_Terminal_Index;
   end record;

   type Node_Fabric is null record;

   function New_Token
     (Self : access Node_Fabric)
      return Node_Access;

   function New_Node
     (Self       : access Node_Fabric;
      Production : Anagram.Grammars.Production_Index)
      return Node_Access;

   function New_Alternative
     (Self : access Node_Fabric;
      NT   : Anagram.Grammars.Non_Terminal_Index)
      return Node_Access;

   procedure Set_Child
     (Self    : access Node_Fabric;
      Object  : Node_Access;
      Index   : Positive;
      Value   : Node_Access);

   procedure Reference
     (Self   : access Node_Fabric;
      Object : Node_Access);

   procedure Dereference
     (Self   : access Node_Fabric;
      Object : in out Node_Access);

   procedure Print (Self : Node; Input : Anagram.Grammars.Grammar);

end AST;
