------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Gela.Grammars.Attributed;
with Gela.Grammars.Attributed.Extended;

package Gela.Grammars_Convertors is

   function Convert
     (Input : access Gela.Grammars.Attributed.Extended.Grammar;
      Left  : Boolean)
     return Gela.Grammars.Attributed.Grammar;
   --  If Left = True convert list as LIST := ITEM LIST | ITEM
   --  otherwise LIST := LIST ITEM | ITEM

end Gela.Grammars_Convertors;
