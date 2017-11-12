--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

package body Anagram.String_Sources is

   --------------
   -- Get_Next --
   --------------

   overriding function Get_Next
     (Self : not null access String_Source)
      return Anagram.Abstract_Sources.Code_Unit_32
   is
   begin
      if Self.Cursor.Has_Element then
         return Result : Anagram.Abstract_Sources.Code_Unit_32 do
            Result := Wide_Wide_Character'Pos
              (Self.Cursor.Element);
            Self.Cursor.Next;
         end return;
      else
         return Anagram.Abstract_Sources.End_Of_Input;
      end if;
   end Get_Next;

   ------------
   -- Create --
   ------------

   procedure Create
     (Self : out String_Source;
      Text : League.Strings.Universal_String) is
   begin
      Self.Text := Text;
      Self.Cursor.First (Self.Text);
   end Create;

end Anagram.String_Sources;
