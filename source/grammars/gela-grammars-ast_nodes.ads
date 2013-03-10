------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

package Gela.Grammars.AST_Nodes is

   type Node is abstract tagged null record;
   type Node_Access is access all Node'Class;

   type Node_Fabric is abstract tagged null record;

   function New_Token (Self : Node_Fabric) return Node_Access is abstract;

   function New_Node
     (Self       : Node_Fabric;
      Production : Production_Index) return Node_Access is abstract;

   function New_Alternative
     (Self : Node_Fabric;
      NT   : Non_Terminal_Index) return Node_Access is abstract;

   procedure Set_Child
     (Self   : Node_Fabric;
      Object : Node_Access;
      Index  : Positive;
      Value  : Node_Access) is abstract;

   procedure Reference
     (Self   : Node_Fabric;
      Object : Node_Access;
      Step   : Integer := 1) is abstract;

end Gela.Grammars.AST_Nodes;
