------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Gela.Grammars.Tools;

package body Gela.Grammars.LR.Simple is

   -----------
   -- Build --
   -----------

   function Build (Input : Grammar) return LR_Tables.Table is
      type Non_Terminal_Map is array (Non_Terminal_Index range <>) of Boolean;

      procedure Add_Reduces
        (Added : in out Non_Terminal_Map;
         State : State_Index;
         Prod  : Production_Index;
         Next  : Part_Index);
      --  Add item and it's closure to table

      First  : Tools.Terminal_Set_Per_Non_Terminal
        (Input.Last_Terminal, Input.Last_Non_Terminal);

      Follow : Tools.Terminal_Set_Per_Non_Terminal
        (Input.Last_Terminal, Input.Last_Non_Terminal);

      C          : constant Set_Of_LR_Item_Set_Access := Items (Input);
      Result     : LR_Tables.Table := LR_Tables.Create
        (Last_State        => C.Last_State,
         Last_Terminal     => Input.Last_Terminal,
         Last_Non_Terminal => Input.Last_Non_Terminal);

      -----------------
      -- Add_Reduces --
      -----------------

      procedure Add_Reduces
        (Added : in out Non_Terminal_Map;
         State : State_Index;
         Prod  : Production_Index;
         Next  : Part_Index)
      is
         P  : Production renames Input.Production (Prod);
         NT : constant Non_Terminal_Index := P.Parent;
      begin
         if Next > P.Last then  --  A := α .
            if NT = Input.Root then  --  S' := S .
               LR_Tables.Set_Finish (Result, State);
            else
               for T in 0 .. Input.Last_Terminal loop
                  if Follow.Map (NT, T) then
                     LR_Tables.Set_Reduce (Result, State, T, Prod);
                  end if;
               end loop;
            end if;
         elsif Input.Part (Next).Is_Non_Terminal_Reference then
            --  A := α . B β
            --  Add closure of kernel item
            declare
               B : Non_Terminal renames
                 Input.Non_Terminal (Input.Part (Next).Denote);
            begin
               if not Added (B.Index) then
                  Added (B.Index) := True;

                  for P in B.First .. B.Last loop
                     Add_Reduces (Added, State, P, Input.Production (P).First);
                  end loop;
               end if;
            end;
         end if;
      end Add_Reduces;

   begin
      Tools.Get_First (Input, First);
      Tools.Get_Follow (Input, First, Follow);

      for State in 1 .. C.Last_State loop
         declare
            Target  : State_Count;
            Set     : constant LR_Item_Set := To_Set (C, State);
            Added   : Non_Terminal_Map (1 .. Input.Last_Non_Terminal) :=
              (others => False);
         begin
            for Item of Set loop
               declare
                  Next : Part_Index;
                  Prod : constant Production_Index :=
                    To_Production (Input, Item);
               begin
                  if Item = 0 then
                     Next := Input.Production (Prod).First;
                  else
                     Next := Part_Index (Item + 1);
                  end if;

                  Add_Reduces (Added, State, Prod, Next);
               end;
            end loop;

            --  Add shifts on terminals
            for T in Input.Terminal'Range loop
               Target := C.Go_To (To_Reference (T), State);

               if Target /= 0 then
                  LR_Tables.Set_Shift (Result, State, T, Target);
               end if;
            end loop;

            --  Add shifts on non-terminals
            for NT in Input.Non_Terminal'Range loop
               Target := C.Go_To (To_Reference (NT), State);

               if Target /= 0 then
                  LR_Tables.Set_Shift (Result, State, NT, Target);
               end if;
            end loop;
         end;
      end loop;

      return Result;
   end Build;

end Gela.Grammars.LR.Simple;
