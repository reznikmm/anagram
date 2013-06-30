------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------
--  Simple interface to fetch tokens when parsing

package Gela.Grammars.Lexers is
   pragma Preelaborate;

   type Lexer is limited interface;

   function Next (Self : in out Lexer) return Terminal_Count is abstract;

end Gela.Grammars.Lexers;
