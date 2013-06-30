------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Gela.Grammars.Lexers;
with Gela.Grammars.LR_Tables;

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

package Gela.Grammars.RNGLR is

   procedure Parse
     (G : Grammar;
      T : LR_Tables.Table;
      F : access Node_Fabric;
      L : in out Gela.Grammars.Lexers.Lexer'Class;
      Tree : out Node_Access);

end Gela.Grammars.RNGLR;
