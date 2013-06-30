------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Gela.Grammars;

package Gela.Grammars_Convertors is

   function Convert
     (Input : Gela.Grammars.Grammar;
      Left  : Boolean)
      return Gela.Grammars.Grammar;
   --  Return grammar with expanded options and lists as plain rules.
   --  If Left = True convert list as LIST := ITEM LIST | ITEM
   --  otherwise LIST := LIST ITEM | ITEM

   function Convert_With_Empty
     (Input : Gela.Grammars.Grammar)
      return Gela.Grammars.Grammar;

end Gela.Grammars_Convertors;
