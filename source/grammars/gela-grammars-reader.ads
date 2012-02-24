------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Gela.Grammars.Attributed.Extended;

package Gela.Grammars.Reader is

   function Read (File_Name : String) return
     Gela.Grammars.Attributed.Extended.Grammar;

end Gela.Grammars.Reader;
