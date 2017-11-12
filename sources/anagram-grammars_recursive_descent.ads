--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Anagram.Grammars;

package Anagram.Grammars_Recursive_Descent is

   procedure Generate
     (Self : Anagram.Grammars.Grammar;
      File : String;
      Ok   : out Boolean);

end Anagram.Grammars_Recursive_Descent;
