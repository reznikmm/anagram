------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Anagram.Grammars;
with Anagram.Grammars.LR_Tables;

package Anagram.Grammars_Debug is

   procedure Print (Self : Anagram.Grammars.Grammar);

   procedure Print_Conflicts
     (Self  : Anagram.Grammars.Grammar;
      Table : Anagram.Grammars.LR_Tables.Table);

end Anagram.Grammars_Debug;
