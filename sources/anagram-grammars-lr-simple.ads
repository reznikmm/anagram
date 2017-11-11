------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Anagram.Grammars.LR_Tables;

package Anagram.Grammars.LR.Simple is

   function Build (Input : Grammar) return LR_Tables.Table_Access;

end Anagram.Grammars.LR.Simple;
