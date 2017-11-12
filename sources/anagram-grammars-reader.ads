--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

package Anagram.Grammars.Reader is

   function Read
     (File_Name : String;
      Tail_List : Boolean := False) return Anagram.Grammars.Grammar;
   --  If Tail_List is False then a list expanded as
   --  LIST ::= [LIST] <head> Item
   --  If Tail_List is True then a list expanded as
   --  LIST ::= Item [LIST] <tail>

end Anagram.Grammars.Reader;
