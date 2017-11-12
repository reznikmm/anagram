--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Anagram.Grammars.LR_Tables;

package Anagram.Grammars.LR.Simple is

   function Build (Input : Grammar) return LR_Tables.Table_Access;

end Anagram.Grammars.LR.Simple;
