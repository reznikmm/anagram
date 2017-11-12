--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Anagram.Grammars.Lexers;
with Anagram.Grammars.LR_Tables;

generic
   type Node_Access is private;

   Null_Node : in Node_Access;

   type Node_Fabric (<>) is limited private;

   with function New_Token
     (Self : access Node_Fabric) return Node_Access is <>;

   with function New_Node
     (Self       : access Node_Fabric;
      Production : Production_Index) return Node_Access is <>;

   with function New_Alternative
     (Self : access Node_Fabric;
      NT   : Non_Terminal_Index) return Node_Access is <>;

   with procedure Set_Child
     (Self   : access Node_Fabric;
      Object : Node_Access;
      Index  : Positive;
      Value  : Node_Access) is <>;

   with procedure Reference
     (Self   : access Node_Fabric;
      Object : Node_Access) is <>;

   with procedure Dereference
     (Self   : access Node_Fabric;
      Object : in out Node_Access) is <>;

package Anagram.Grammars.RNGLR is

   procedure Parse
     (G : Grammar;
      T : LR_Tables.Table;
      F : access Node_Fabric;
      L : in out Anagram.Grammars.Lexers.Lexer'Class;
      Tree : out Node_Access);

end Anagram.Grammars.RNGLR;
