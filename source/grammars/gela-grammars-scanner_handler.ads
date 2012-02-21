with Ag_Tokens;
limited with Gela.Grammars.Scanners;
with Gela.Grammars.Scanner_Handlers;

package Gela.Grammars.Scanner_Handler is

   type Handler is new Gela.Grammars.Scanner_Handlers.Handler with private;

   procedure Equal_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Inherited_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Synthesized_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Attributes_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Rules_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Identifier_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Token_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Open_Rule_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Rule_Body_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Close_Rule_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure For_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Regexp_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Semicolon_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Open_Production_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Close_Production_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Open_Part_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Close_Part_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Open_List_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Close_List_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Open_Option_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Close_Option_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Colon_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Spaces
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

   procedure Comment
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean) is null;

private
   type Handler is new Gela.Grammars.Scanner_Handlers.Handler with null record;

end Gela.Grammars.Scanner_Handler;
