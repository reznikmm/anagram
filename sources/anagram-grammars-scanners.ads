--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Abstract_Sources;
with League.Strings;
with Anagram.Grammars.Scanner_Handlers;
with Ag_Tokens;

with Anagram.Grammars.Scanner_Types; use Anagram.Grammars.Scanner_Types;

package Anagram.Grammars.Scanners is

   subtype Token is Ag_Tokens.Token;
   type Scanner is tagged limited private;

   procedure Set_Source
     (Self : in out Scanner'Class;
      Source : not null Abstract_Sources.Source_Access);

   procedure Set_Handler
     (Self    : in out Scanner'Class;
      Handler : not null Anagram.Grammars.Scanner_Handlers.Handler_Access);

   subtype Start_Condition is State;

   procedure Set_Start_Condition
    (Self : in out Scanner'Class; Condition : Start_Condition);

   function Get_Start_Condition
     (Self : Scanner'Class) return Start_Condition;

   procedure Get_Token (Self : access Scanner'Class; Result : out Token);

   function Get_Text
     (Self : Scanner'Class) return League.Strings.Universal_String;

   function Get_Token_Length (Self : Scanner'Class) return Positive;
   function Get_Token_Position (Self : Scanner'Class) return Positive;
private

   Buffer_Half_Size : constant := 2048;

   subtype Buffer_Index is Positive range 1 .. 2 * Buffer_Half_Size;

   type Character_Class_Array is array (Buffer_Index) of Character_Class;

   Error_Character : constant Character_Class := 0;
   Error_State : constant State := State'Last;

   type Buffer_Half is (Low, High);

   type Buffer_Offset is array (Buffer_Half) of Natural;

   type Scanner is tagged limited record
      Handler : Anagram.Grammars.Scanner_Handlers.Handler_Access;
      Source  : Abstract_Sources.Source_Access;
      Start   : State := INITIAL;
      Next    : Buffer_Index := 1;
      From    : Buffer_Index := 1;
      To      : Natural := 0;
      Rule    : Scanner_Types.Rule_Index;
      Offset  : Buffer_Offset := (0, 0);
      Buffer  : Wide_Wide_String (Buffer_Index) :=
        (1 => Wide_Wide_Character'Val (Abstract_Sources.End_Of_Buffer),
         others => <>);
      Classes : Character_Class_Array := (1 => Error_Character, others => <>);
   end record;

   procedure Read_Buffer (Self : in out Scanner'Class);

end Anagram.Grammars.Scanners;
