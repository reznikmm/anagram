--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Anagram.Grammars;
with Anagram.Grammars.LR_Tables;

package Anagram.Grammars_Debug is

   procedure Print (Self : Anagram.Grammars.Grammar);

   procedure Print_Conflicts
     (Self  : Anagram.Grammars.Grammar;
      Table : Anagram.Grammars.LR_Tables.Table);

end Anagram.Grammars_Debug;
