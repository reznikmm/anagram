--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Anagram.Grammars.LR_Tables;

package Anagram.Grammars.LR.LALR is
   pragma Preelaborate;

   function Build
     (Input        : Grammar;
      Right_Nulled : Boolean) return LR_Tables.Table_Access;
   --  Build LARL table.
   --  If Right_Nulled then include reduction on LR items in form
   --  A ::= x1 ... xm · B1 ... Bt, where B1 ... Bt => ε. In this case
   --  reduction includes position of m.

end Anagram.Grammars.LR.LALR;
