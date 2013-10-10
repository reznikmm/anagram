------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

package Gela.Grammars.LR_Parsers is
   pragma Preelaborate;

   type State_Index is mod 2 ** 16;
   for State_Index'Size use 16;

   type Action_Kinds is (Shift, Reduce, Error, Finish);

   type Action (Kind : Action_Kinds := Error) is record
      case Kind is
         when Shift =>
            State : State_Index;
         when Reduce =>
            Prod  : Production_Index;
            NT    : Non_Terminal_Index;
            Parts : Natural;
         when Error | Finish =>
            null;
      end case;
   end record;

   generic
      type Node is private;
      --  AST node
      type Node_Array is array (Positive range <>) of Node;
      --  List of AST nodes

      type Lexer (<>) is limited private;
      type Parser (<>) is limited private;

      with procedure Next_Token
        (Self  : access Lexer;
         Token : out Terminal_Count;
         Value : out Node);

      with procedure Next_Action
        (State : State_Index;
         Token : Terminal_Count;
         Value : out Action);

      with function Go_To
        (State : State_Index;
         NT    : Non_Terminal_Index) return State_Index;

      with procedure On_Reduce
        (Self  : access Parser;
         Prod  : Gela.Grammars.Production_Index;
         Nodes : in out Node_Array);

   procedure Parse
     (Self    : access Parser;
      Input   : access Lexer;
      Root    : out Node;
      Success : out Boolean);

end Gela.Grammars.LR_Parsers;
