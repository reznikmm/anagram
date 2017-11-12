--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

package Anagram.Grammars.AST_Nodes is

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

end Anagram.Grammars.AST_Nodes;
