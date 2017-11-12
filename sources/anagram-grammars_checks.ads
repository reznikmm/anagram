--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Anagram.Grammars;

package Anagram.Grammars_Checks is

   function Is_L_Attributed
     (Self : Anagram.Grammars.Grammar)
      return Boolean;
   --  All inherited attributes of a part at right hand side depends only on
   --  inherited attributes on left hand side or
   --  attributes of 'prefix' of the part.

   function Is_Well_Formed
     (Self    : Anagram.Grammars.Grammar;
      Verbose : Boolean)
      return Boolean;
   --  Each production has exactly one rule for each LHS synthesized attribute
   --  and for each RHS symbols' inherited attribute

end Anagram.Grammars_Checks;
