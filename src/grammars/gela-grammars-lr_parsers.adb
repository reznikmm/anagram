------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

package body Gela.Grammars.LR_Parsers is

   type State_Array is array (Positive range <>) of State_Index;

   Stack_Length : constant := 256;

   -----------
   -- Parse --
   -----------

   procedure Parse
     (Self    : access Parser;
      Input   : access Lexer;
      Root    : out Node;
      Success : out Boolean)
   is
      type Stack is record
         Top   : Natural;
         State : State_Array (1 .. Stack_Length);
         Node  : Node_Array (1 .. Stack_Length);
      end record;

      procedure Push
        (Self  : in out Stack;
         State : State_Index;
         Value : Node);

      ----------
      -- Push --
      ----------

      procedure Push
        (Self  : in out Stack;
         State : State_Index;
         Value : Node) is
      begin
         Self.Top := Self.Top + 1;
         Self.State (Self.Top) := State;
         Self.Node (Self.Top) := Value;
      end Push;

      S          : Stack;
      Token      : Grammars.Terminal_Count;
      Token_Node : Node;
      State      : State_Index := 1;
      Next       : Action;
   begin
      S.Top := 0; --  Clear stack
      Next_Token (Input, Token, Token_Node);

      loop
         Next_Action (State, Token, Next);
         case Next.Kind is
            when Shift =>
               Push (S, State, Token_Node);
               Next_Token (Input, Token, Token_Node);
               State := Next.State;
            when Reduce =>
               declare
                  subtype First_Nodes is Node_Array (1 .. Next.Parts);
               begin
                  S.Top := S.Top - Next.Parts + 1;

                  On_Reduce
                    (Self  => Self,
                     Prod  => Next.Prod,
                     Nodes => First_Nodes
                       (S.Node (S.Top .. S.Top + Next.Parts - 1)));

                  State := Go_To (S.State (S.Top), Next.NT);
               end;
            when Finish =>
               Root := S.Node (S.Top);
               Success := True;
               exit;
            when Error =>
               Success := False;
               exit;
         end case;
      end loop;
   end Parse;

end Gela.Grammars.LR_Parsers;
