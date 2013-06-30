------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Gela.Grammars;

package Gela.Grammars_Checks is

   function Is_L_Attributed
     (Self : Gela.Grammars.Grammar)
      return Boolean;
   --  All inherited attributes of a part at right hand side depends only on
   --  inherited attributes on left hand side or
   --  attributes of 'prefix' of the part.

   function Is_Well_Formed
     (Self    : Gela.Grammars.Grammar;
      Verbose : Boolean)
      return Boolean;
   --  Each production has exactly one rule for each LHS synthesized attribute
   --  and for each RHS symbols' inherited attribute

end Gela.Grammars_Checks;
