------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Gela.Grammars;
with Gela.Grammars.Attributed;
with Gela.Grammars.Extended;
with Gela.Grammars.Attributed.Extended;

package Gela.Grammars_Debug is

   procedure Print (Self : access Gela.Grammars.Grammar);
   procedure Print (Self : access Gela.Grammars.Extended.Grammar);
   procedure Print (Self : access Gela.Grammars.Attributed.Grammar);
   procedure Print (Self : access Gela.Grammars.Attributed.Extended.Grammar);

end Gela.Grammars_Debug;
