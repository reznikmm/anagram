------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Gela.Grammars.Attributed;

package Gela.Grammars_Recursive_Descent is

   procedure Bbb
     (Self : access Gela.Grammars.Attributed.Grammar;
      Ok   : out Boolean);

end Gela.Grammars_Recursive_Descent;
