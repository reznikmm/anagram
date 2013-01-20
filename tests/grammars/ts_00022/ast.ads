with Gela.Grammars.AST_Nodes;

package AST is
   type Node_Array is array (1 .. 4) of Gela.Grammars.AST_Nodes.Node_Access;

   type Node is new Gela.Grammars.AST_Nodes.Node with record
      Identifier     : Positive;
      Is_Token       : Boolean;
      Is_Alternative : Boolean;
      Children       : Node_Array;
      Prod           : Gela.Grammars.Production_Index;
      NT             : Gela.Grammars.Non_Terminal_Index;
   end record;

   ---------------
   -- Set_Child --
   ---------------

   overriding procedure Set_Child
     (Self  : in out Node;
      Index : Positive;
      Value : access Gela.Grammars.AST_Nodes.Node'Class);

   type Node_Fabric is
     new Gela.Grammars.AST_Nodes.Node_Fabric with null record;

   overriding function New_Token
     (Self : Node_Fabric)
      return Gela.Grammars.AST_Nodes.Node_Access;

   overriding function New_Node
     (Self       : Node_Fabric;
      Production : Gela.Grammars.Production_Index)
      return Gela.Grammars.AST_Nodes.Node_Access;

   overriding function New_Alternative
     (Self : Node_Fabric;
      NT   : Gela.Grammars.Non_Terminal_Index)
      return Gela.Grammars.AST_Nodes.Node_Access;

   procedure Print (Self : Node; Input : Gela.Grammars.Grammar);

end AST;
