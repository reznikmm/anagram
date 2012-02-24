------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Ag_Tokens;
limited with Gela.Grammars.Scanners;
with Gela.Grammars.Scanner_Handlers;

package Gela.Grammars.Scanner_Handler is

   type Handler is new Gela.Grammars.Scanner_Handlers.Handler with private;

   procedure Equal_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Inherited_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Synthesized_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Attributes_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Rules_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Identifier_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Token_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Open_Rule_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Rule_Body_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Close_Rule_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure For_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Regexp_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Semicolon_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Open_Production_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Close_Production_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Open_Part_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Close_Part_Name_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Open_List_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Close_List_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Open_Option_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Close_Option_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Colon_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   procedure Or_Token
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

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

   procedure New_Line
     (Self    : not null access Handler;
      Scanner : not null access Gela.Grammars.Scanners.Scanner'Class;
      Token   : out Ag_Tokens.Token;
      Skip    : in out Boolean);

   function Get_Line (Self : Handler) return Positive;

private
   type Handler is new Gela.Grammars.Scanner_Handlers.Handler with record
      Line : Positive := 1;
   end record;

end Gela.Grammars.Scanner_Handler;
