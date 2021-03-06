--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Ag_Tokens;
limited with Anagram.Grammars.Scanners;
with Anagram.Grammars.Scanner_Handlers;
with Anagram.Grammars.Scanner_Types;

package Anagram.Grammars.Scanner_Handler is

   type Handler is new Anagram.Grammars.Scanner_Handlers.Handler with private;

   procedure Equal_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Inherited_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Synthesized_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Local_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Attributes_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Rules_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Identifier_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Token_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure With_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Priority_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Integer_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Open_Rule_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Rule_Body_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Close_Rule_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Regexp_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Semicolon_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Open_Production_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Close_Production_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Open_Part_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Close_Part_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Open_List_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Close_List_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Open_Option_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Close_Option_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Colon_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Or_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Comma_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Spaces
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Comment
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure New_Line
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   function Get_Line (Self : Handler) return Positive;

private
   type Handler is new Anagram.Grammars.Scanner_Handlers.Handler with record
      Line : Positive := 1;
   end record;

end Anagram.Grammars.Scanner_Handler;
