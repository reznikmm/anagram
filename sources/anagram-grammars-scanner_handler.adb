--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Anagram.Grammars.Scanners;

package body Anagram.Grammars.Scanner_Handler is

   package T renames Ag_Tokens;

   ----------------------
   -- Attributes_Token --
   ----------------------

   procedure Attributes_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.Attributes_Token;
      Scanner.Set_Start_Condition (Anagram.Grammars.Scanner_Types.With_Regexp);
   end Attributes_Token;

   ----------------------
   -- Close_List_Token --
   ----------------------

   procedure Close_List_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.'}';
   end Close_List_Token;

   ------------------------
   -- Close_Option_Token --
   ------------------------

   procedure Close_Option_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.']';
   end Close_Option_Token;

   ---------------------------
   -- Close_Part_Name_Token --
   ---------------------------

   procedure Close_Part_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.'>';
   end Close_Part_Name_Token;

   ---------------------------------
   -- Close_Production_Name_Token --
   ---------------------------------

   procedure Close_Production_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.')';
   end Close_Production_Name_Token;

   ----------------------
   -- Close_Rule_Token --
   ----------------------

   procedure Close_Rule_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.Close_Rule_Token;
   end Close_Rule_Token;

   -----------------
   -- Colon_Token --
   -----------------

   procedure Colon_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.':';
   end Colon_Token;

   -----------------
   -- Comma_Token --
   -----------------

   procedure Comma_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.',';
   end Comma_Token;

   -----------------
   -- Equal_Token --
   -----------------

   procedure Equal_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.Equal_Token;
      Scanner.Set_Start_Condition (Anagram.Grammars.Scanner_Types.INITIAL);
   end Equal_Token;

   ---------------
   --  Get_Line --
   ---------------

   function Get_Line (Self : Handler) return Positive is
   begin
      return Self.Line;
   end Get_Line;

   ----------------------
   -- Identifier_Token --
   ----------------------

   procedure Identifier_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.Identifier_Token;
   end Identifier_Token;

   ---------------------
   -- Inherited_Token --
   ---------------------

   procedure Inherited_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.Inherited_Token;
   end Inherited_Token;

   -------------------
   -- Integer_Token --
   -------------------

   procedure Integer_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.Integer_Token;
   end Integer_Token;

   -----------------
   -- Local_Token --
   -----------------

   procedure Local_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.Local_Token;
   end Local_Token;


   --------------
   -- New_Line --
   --------------

   procedure New_Line
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Token);
      pragma Unreferenced (Rule);
   begin
      Self.Line := Self.Line + Scanner.Get_Token_Length;
      Skip := True;
   end New_Line;

   ---------------------
   -- Open_List_Token --
   ---------------------

   procedure Open_List_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.'{';
   end Open_List_Token;

   -----------------------
   -- Open_Option_Token --
   -----------------------

   procedure Open_Option_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.'[';
   end Open_Option_Token;

   --------------------------
   -- Open_Part_Name_Token --
   --------------------------

   procedure Open_Part_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.'<';
   end Open_Part_Name_Token;

   --------------------------------
   -- Open_Production_Name_Token --
   --------------------------------

   procedure Open_Production_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.'(';
   end Open_Production_Name_Token;

   ---------------------
   -- Open_Rule_Token --
   ---------------------

   procedure Open_Rule_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.Open_Rule_Token;
      Scanner.Set_Start_Condition (Anagram.Grammars.Scanner_Types.In_Rule);
   end Open_Rule_Token;

   --------------
   -- Or_Token --
   --------------

   procedure Or_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.'|';
   end Or_Token;

   --------------------
   -- Priority_Token --
   --------------------

   procedure Priority_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.Priority_Token;
   end Priority_Token;

   ------------------
   -- Regexp_Token --
   ------------------

   procedure Regexp_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.Regexp_Token;
   end Regexp_Token;

   ---------------------
   -- Rule_Body_Token --
   ---------------------

   procedure Rule_Body_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.Rule_Body_Token;
      Scanner.Set_Start_Condition (Anagram.Grammars.Scanner_Types.INITIAL);
   end Rule_Body_Token;

   -----------------
   -- Rules_Token --
   -----------------

   procedure Rules_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Rule);
      pragma Unreferenced (Scanner);
   begin
      Skip := False;
      Token := T.Rules_Token;
   end Rules_Token;

   ---------------------
   -- Semicolon_Token --
   ---------------------

   procedure Semicolon_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.';';
      Scanner.Set_Start_Condition (Anagram.Grammars.Scanner_Types.With_Regexp);
   end Semicolon_Token;

   -----------------------
   -- Synthesized_Token --
   -----------------------

   procedure Synthesized_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.Synthesized_Token;
   end Synthesized_Token;

   -----------------
   -- Token_Token --
   -----------------

   procedure Token_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.Token_Token;
   end Token_Token;

   ----------------
   -- With_Token --
   ----------------

   procedure With_Token
     (Self    : not null access Handler;
      Scanner : not null access Anagram.Grammars.Scanners.Scanner'Class;
      Rule    : Anagram.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
      pragma Unreferenced (Rule);
   begin
      Skip := False;
      Token := T.With_Token;
   end With_Token;

end Anagram.Grammars.Scanner_Handler;
