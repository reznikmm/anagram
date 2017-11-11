------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

package Anagram.Grammars.Reader is

   function Read
     (File_Name : String;
      Tail_List : Boolean := False) return Anagram.Grammars.Grammar;
   --  If Tail_List is False then a list expanded as
   --  LIST ::= [LIST] <head> Item
   --  If Tail_List is True then a list expanded as
   --  LIST ::= Item [LIST] <tail>

end Anagram.Grammars.Reader;
