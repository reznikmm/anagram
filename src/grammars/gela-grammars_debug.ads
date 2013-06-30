------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Gela.Grammars;
with Gela.Grammars.LR_Tables;

package Gela.Grammars_Debug is

   procedure Print (Self : Gela.Grammars.Grammar);

   procedure Print_Conflicts
     (Self  : Gela.Grammars.Grammar;
      Table : Gela.Grammars.LR_Tables.Table);

end Gela.Grammars_Debug;
