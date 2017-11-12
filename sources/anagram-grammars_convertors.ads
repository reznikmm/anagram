--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Anagram.Grammars;

package Anagram.Grammars_Convertors is

   function Convert
     (Input : Anagram.Grammars.Grammar;
      Left  : Boolean)
      return Anagram.Grammars.Grammar;
   --  Return grammar with expanded options and lists as plain rules.
   --  If Left = True convert list as LIST := ITEM LIST | ITEM
   --  otherwise LIST := LIST ITEM | ITEM

   function Convert_With_Empty
     (Input : Anagram.Grammars.Grammar)
      return Anagram.Grammars.Grammar;

end Anagram.Grammars_Convertors;
