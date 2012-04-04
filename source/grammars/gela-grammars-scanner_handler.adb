------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Gela.Grammars.Scanner_Types;
with Gela.Grammars.Scanners;

package body Gela.Grammars.Scanner_Handler is

   package T renames Ag_Tokens;

   ----------------------
   -- Attributes_Token --
   ----------------------

   procedure Attributes_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
   begin
      Skip := False;
      Token := T.Attributes_Token;
      Scanner.Set_Start_Condition (Gela.Grammars.Scanner_Types.With_Regexp);
   end Attributes_Token;

   ----------------------
   -- Close_List_Token --
   ----------------------

   procedure Close_List_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
   begin
      Skip := False;
      Token := T.'}';
   end Close_List_Token;

   ------------------------
   -- Close_Option_Token --
   ------------------------

   procedure Close_Option_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
   begin
      Skip := False;
      Token := T.']';
   end Close_Option_Token;

   ---------------------------
   -- Close_Part_Name_Token --
   ---------------------------

   procedure Close_Part_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
   begin
      Skip := False;
      Token := T.'>';
   end Close_Part_Name_Token;

   ---------------------------------
   -- Close_Production_Name_Token --
   ---------------------------------

   procedure Close_Production_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
   begin
      Skip := False;
      Token := T.')';
   end Close_Production_Name_Token;

   ----------------------
   -- Close_Rule_Token --
   ----------------------

   procedure Close_Rule_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
   begin
      Skip := False;
      Token := T.Close_Rule_Token;
   end Close_Rule_Token;

   -----------------
   -- Colon_Token --
   -----------------

   procedure Colon_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
   begin
      Skip := False;
      Token := T.':';
   end Colon_Token;

   -----------------
   -- Equal_Token --
   -----------------

   procedure Equal_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
   begin
      Skip := False;
      Token := T.Equal_Token;
      Scanner.Set_Start_Condition (Gela.Grammars.Scanner_Types.INITIAL);
   end Equal_Token;

   ---------------
   -- For_Token --
   ---------------

   procedure For_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
   begin
      Skip := False;
      Token := T.For_Token;
      Scanner.Set_Start_Condition (Gela.Grammars.Scanner_Types.With_Regexp);
   end For_Token;

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
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
   begin
      Skip := False;
      Token := T.Identifier_Token;
   end Identifier_Token;

   ---------------------
   -- Inherited_Token --
   ---------------------

   procedure Inherited_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
   begin
      Skip := False;
      Token := T.Inherited_Token;
   end Inherited_Token;

   --------------
   -- New_Line --
   --------------

   procedure New_Line
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Token);
   begin
      Self.Line := Self.Line + Scanner.Get_Token_Length;
      Skip := True;
   end New_Line;

   ---------------------
   -- Open_List_Token --
   ---------------------

   procedure Open_List_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
   begin
      Skip := False;
      Token := T.'{';
   end Open_List_Token;

   -----------------------
   -- Open_Option_Token --
   -----------------------

   procedure Open_Option_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
   begin
      Skip := False;
      Token := T.'[';
   end Open_Option_Token;

   --------------------------
   -- Open_Part_Name_Token --
   --------------------------

   procedure Open_Part_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
   begin
      Skip := False;
      Token := T.'<';
   end Open_Part_Name_Token;

   --------------------------------
   -- Open_Production_Name_Token --
   --------------------------------

   procedure Open_Production_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
   begin
      Skip := False;
      Token := T.'(';
   end Open_Production_Name_Token;

   ---------------------
   -- Open_Rule_Token --
   ---------------------

   procedure Open_Rule_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
   begin
      Skip := False;
      Token := T.Open_Rule_Token;
      Scanner.Set_Start_Condition (Gela.Grammars.Scanner_Types.In_Rule);
   end Open_Rule_Token;

   --------------
   -- Or_Token --
   --------------

   procedure Or_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
   begin
      Skip := False;
      Token := T.'|';
   end Or_Token;

   ------------------
   -- Regexp_Token --
   ------------------

   procedure Regexp_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
   begin
      Skip := False;
      Token := T.Regexp_Token;
   end Regexp_Token;

   ---------------------
   -- Rule_Body_Token --
   ---------------------

   procedure Rule_Body_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
   begin
      Skip := False;
      Token := T.Rule_Body_Token;
      Scanner.Set_Start_Condition (Gela.Grammars.Scanner_Types.INITIAL);
   end Rule_Body_Token;

   -----------------
   -- Rules_Token --
   -----------------

   procedure Rules_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
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
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
   begin
      Skip := False;
      Token := T.';';
      Scanner.Set_Start_Condition (Gela.Grammars.Scanner_Types.With_Regexp);
   end Semicolon_Token;

   -----------------------
   -- Synthesized_Token --
   -----------------------

   procedure Synthesized_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
   begin
      Skip := False;
      Token := T.Synthesized_Token;
   end Synthesized_Token;

   -----------------
   -- Token_Token --
   -----------------

   procedure Token_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean)
   is
      pragma Unreferenced (Self);
      pragma Unreferenced (Scanner);
   begin
      Skip := False;
      Token := T.Token_Token;
   end Token_Token;

end Gela.Grammars.Scanner_Handler;
