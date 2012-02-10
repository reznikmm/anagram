------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

private
package Gela.Grammars.Common is

   procedure Copy_Terminals is new Constructor_Nodes.Generic_Copy_Terminals
     (Terminal, Terminal_Array);

   procedure Copy_Non_Terminals is
     new Constructor_Nodes.Generic_Copy_Non_Terminals
       (Non_Terminal, Non_Terminal_Array);

   procedure Copy_Productions is
     new Constructor_Nodes.Generic_Copy_Productions
       (Production, Production_Array);

end Gela.Grammars.Common;
