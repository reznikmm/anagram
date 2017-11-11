------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Anagram.Grammars;

package Anagram.Grammars_Recursive_Descent is

   procedure Generate
     (Self : Anagram.Grammars.Grammar;
      File : String;
      Ok   : out Boolean);

end Anagram.Grammars_Recursive_Descent;
