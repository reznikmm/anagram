------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Gela.Grammars.LR_Tables;

package Gela.Grammars.LR.LALR is

   function Build
     (Input        : Grammar;
      Right_Nulled : Boolean) return LR_Tables.Table;
   --  Build LARL table.
   --  If Right_Nulled then include reduction on LR items in form
   --  A ::= x1 ... xm · B1 ... Bt, where B1 ... Bt => ε. In this case
   --  reduction includes position of m.

end Gela.Grammars.LR.LALR;
