--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

package body Anagram.Grammars.Conflicts is

   --------------------
   -- Check_Priority --
   --------------------

   procedure Check_Priority
     (Self : in out Resolver;
      Prec : Precedence_Value) is
   begin
      if Self.Checks.Contains (Prec.Level) then
         if Self.Checks (Prec.Level) /= Prec.Associative then
            raise Constraint_Error;
         end if;
      else
         Self.Checks.Insert (Prec.Level, Prec.Associative);
      end if;
   end Check_Priority;

   -------------
   -- Resolve --
   -------------

   procedure Resolve
     (Self  : in out Resolver;
      Input : Grammar;
      Table : in out LR_Tables.Table)
   is
      use Anagram.Grammars.LR_Tables;
      use type LR.State_Count;

      Shift  : LR.State_Count;
      Reduce : Reduce_Iterator;
   begin
      for State in 1 .. Table.Last_State loop
         for T in End_Of_File .. Input.Last_Terminal loop
            Shift := Table.Shift (State, T);
            Reduce := Table.Reduce (State, T);

            if not Is_Empty (Reduce) and Shift > 0 then
               --  Found conflict
               Self.Try_To_Resolve (Input, Table, State, T);
            end if;
         end loop;
      end loop;
   end Resolve;

   --------------------
   -- Try_To_Resolve --
   --------------------

   procedure Try_To_Resolve
     (Self     : in out Resolver;
      Input    : Grammar;
      Table    : in out LR_Tables.Table;
      State    : LR.State_Index;
      Terminal : Terminal_Index)
   is
      use Anagram.Grammars.LR_Tables;

      Count           : Natural := 0;
      Production_Item : Precedence_Value;
      Terminal_Item   : constant Precedence_Value :=
        Input.Terminal (Terminal).Precedence;
      Reduce          : Reduce_Iterator := Table.Reduce (State, Terminal);
      Prod            : Production_Index;
   begin
      if Terminal_Item.Associative = Undefined then
         return;
      end if;

      while not Is_Empty (Reduce) loop
         Prod := LR_Tables.Production (Reduce);
         Production_Item := Input.Production (Prod).Precedence;

         if Production_Item.Associative = Undefined then
            return;
         elsif Input.Production (Prod).Last /= LR_Tables.Part (Reduce) then
            raise Program_Error with "RNGLR unimpl";
         end if;

         Count := Count + 1;
         Table.Next (Reduce);
      end loop;

      if Count > 1 then
         raise Program_Error with "Reduce/Reduce unimpl";
      end if;

      Self.Check_Priority (Terminal_Item);
      Self.Check_Priority (Production_Item);

      if Terminal_Item.Level > Production_Item.Level then
         Table.Remove_Reduce (State, Terminal, Prod);
      elsif Terminal_Item.Level < Production_Item.Level then
         Table.Remove_Shift (State, Terminal);
      elsif Terminal_Item.Associative = Left then
         Table.Remove_Shift (State, Terminal);
      elsif Terminal_Item.Associative = Right then
         Table.Remove_Reduce (State, Terminal, Prod);
      else
         Table.Remove_Shift (State, Terminal);
         Table.Remove_Reduce (State, Terminal, Prod);
      end if;
   end Try_To_Resolve;

end Anagram.Grammars.Conflicts;
