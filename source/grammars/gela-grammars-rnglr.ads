------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Gela.Grammars.LR_Tables;
with Gela.Grammars.AST_Nodes;
package Gela.Grammars.RNGLR is

   type Lexer is interface;
   function Next (Self : in out Lexer) return Terminal_Count is abstract;

   procedure Parse
     (G : Grammar;
      T : LR_Tables.Table;
      F : AST_Nodes.Node_Fabric'Class;
      L : in out Lexer'Class;
      Tree : out AST_Nodes.Node_Access);

end Gela.Grammars.RNGLR;
