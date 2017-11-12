--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Anagram.Abstract_Sources;
with League.Strings;
with League.Strings.Cursors.Characters;

package Anagram.String_Sources is
   pragma Preelaborate;

   type String_Source is new Anagram.Abstract_Sources.Abstract_Source
     with private;

   overriding function Get_Next
     (Self : not null access String_Source)
     return Anagram.Abstract_Sources.Code_Unit_32;

   procedure Create
     (Self : out String_Source;
      Text : League.Strings.Universal_String);

private

   type String_Source is new Anagram.Abstract_Sources.Abstract_Source with
   record
      Text   : League.Strings.Universal_String;
      Cursor : League.Strings.Cursors.Characters.Character_Cursor;
   end record;

end Anagram.String_Sources;
