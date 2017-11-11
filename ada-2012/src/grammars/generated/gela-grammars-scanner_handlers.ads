limited with Gela.Grammars.Scanners;
with Ag_Tokens;
with Gela.Grammars.Scanner_Types;

package Gela.Grammars.Scanner_Handlers is

   type Handler is abstract tagged limited null record;

   procedure Equal_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Inherited_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Synthesized_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Attributes_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Rules_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Token_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure With_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Priority_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Integer_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Identifier_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Open_Rule_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Rule_Body_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Close_Rule_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Semicolon_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Open_Production_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Close_Production_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Open_Part_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Close_Part_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Open_List_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Close_List_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Open_Option_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Close_Option_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Colon_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Or_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Comma_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Regexp_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Spaces
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure Comment
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   procedure New_Line
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Rule    : Gela.Grammars.Scanner_Types.Rule_Index;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is abstract;

   type Handler_Access is access all Handler'Class;

end Gela.Grammars.Scanner_Handlers;
