--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

--  Simple interface to fetch tokens when parsing

package Anagram.Grammars.Lexers is
   pragma Preelaborate;

   type Lexer is limited interface;

   function Next (Self : in out Lexer) return Terminal_Count is abstract;

end Anagram.Grammars.Lexers;
