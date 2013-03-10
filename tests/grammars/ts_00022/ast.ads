with Gela.Grammars;

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
      Prod           : Gela.Grammars.Production_Index;
      NT             : Gela.Grammars.Non_Terminal_Index;
   end record;

   type Node_Fabric is null record;

   function New_Token
     (Self : access Node_Fabric)
      return Node_Access;

   function New_Node
     (Self       : access Node_Fabric;
      Production : Gela.Grammars.Production_Index)
      return Node_Access;

   function New_Alternative
     (Self : access Node_Fabric;
      NT   : Gela.Grammars.Non_Terminal_Index)
      return Node_Access;

   procedure Set_Child
     (Self    : access Node_Fabric;
      Object  : Node_Access;
      Index   : Positive;
      Value   : Node_Access);

   procedure Reference
     (Self   : access Node_Fabric;
      Object : Node_Access;
      Step   : Integer := 1);

   procedure Print (Self : Node; Input : Gela.Grammars.Grammar);

end AST;
