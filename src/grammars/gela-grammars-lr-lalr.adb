------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Gela.Grammars.Tools;

package body Gela.Grammars.LR.LALR is

   End_Of_File : constant := 0;

   -----------
   -- Build --
   -----------

   function Build
     (Input        : Grammar;
      Right_Nulled : Boolean) return LR_Tables.Table
   is
      C : Set_Of_LR_Item_Set_Access := Items (Input);
      --  Set of LR(0) items

      type Terminal_Set is array (0 .. Input.Last_Terminal) of Boolean
        with Pack;

      type Terminal_Offset_Map is array (1 .. C.Last_Item) of Terminal_Set;
      --  Set of terminal for each LR_Item in any State

      type Offset_Set is array (1 .. C.Last_Item) of Boolean with Pack;
      --  Set of unconsidered LR_Items

      procedure Add_Recuces
        (Result : in out LR_Tables.Table;
         Added  : in out Tools.Terminal_Set_Indexed_By_Non_Terminal;
         State  : State_Index;
         Prod   : Production_Index;
         Next   : Part_Index;
         LA     : Terminal_Set);
      --  Add reduce of Prod to Result using LA look ahead set and
      --  reduces of transitive closure of LR-item.

      procedure Next_To_Do_Item
        (To_Do   : Offset_Set;
         State   : in out LR.State_Index;
         Offset  : in out LR_Item_Index);
      --  Look for next unconsidered LR_Item and it's State

      procedure Fill_Look_Aheads (Look_Aheads : in out Terminal_Offset_Map);
      --  Fill Look_Aheads table

      function Get_First
        (From, To : Part_Index;     --  This is β
         Default  : Terminal_Set)   --  This is a
         return Terminal_Set;       --  This is FIRST (βa)

      function Check_Added
        (Added  : in out Tools.Terminal_Set_Indexed_By_Non_Terminal;
         Index  : Non_Terminal_Index;
         Set    : in out Terminal_Set) return Boolean;
      --  Check if some of Set not in Added (Index) yet.
      --  Then let "Added := Added or Set" and "Set := Set - Added"

      function Is_Right_Nulled (From, To : Part_Index) return Boolean;
      --  Check if parts => ε and Right_Nulled enabled
      -----------------
      -- Add_Recuces --
      -----------------

      procedure Add_Recuces
        (Result : in out LR_Tables.Table;
         Added  : in out Tools.Terminal_Set_Indexed_By_Non_Terminal;
         State  : State_Index;
         Prod   : Production_Index;
         Next   : Part_Index;
         LA     : Terminal_Set)
      is
         P  : Production renames Input.Production (Prod);
         NT : constant Non_Terminal_Index := P.Parent;
      begin
         if Next > P.Last then  --  A := α .
            if NT = Input.Root then  --  S' := S .
               LR_Tables.Set_Finish (Result, State);
            else
               for T in 0 .. Input.Last_Terminal loop
                  if LA (T) then
                     LR_Tables.Set_Reduce (Result, State, T, Prod, P.Last);
                  end if;
               end loop;
            end if;
         elsif Input.Part (Next).Is_Non_Terminal_Reference then
            if Is_Right_Nulled (Next, P.Last) then
               for T in 0 .. Input.Last_Terminal loop
                  if LA (T) then
                     LR_Tables.Set_Reduce (Result, State, T, Prod, Next - 1);
                  end if;
               end loop;
            end if;

            --  A := α . B β
            --  Add closure of kernel item
            declare
               Set : Terminal_Set :=
                 Get_First (Next + 1, P.Last, LA);
               B : Non_Terminal renames
                 Input.Non_Terminal (Input.Part (Next).Denote);
            begin
               if Check_Added (Added, B.Index, Set) then
                  for P in B.First .. B.Last loop
                     Add_Recuces
                       (Result,
                        Added,
                        State,
                        P,
                        Input.Production (P).First,
                        Set);
                  end loop;
               end if;
            end;
         end if;
      end Add_Recuces;

      -----------------
      -- Check_Added --
      -----------------

      function Check_Added
        (Added  : in out Tools.Terminal_Set_Indexed_By_Non_Terminal;
         Index  : Non_Terminal_Index;
         Set    : in out Terminal_Set) return Boolean
      is
         Result : Boolean := False;
      begin
         for J in Set'Range loop
            if Set (J) then
               if Added (Index, J) then
                  Set (J) := False;
               else
                  Added (Index, J) := True;
                  Result := True;
               end if;
            end if;
         end loop;

         return Result;
      end Check_Added;

      ----------------------
      -- Fill_Look_Aheads --
      ----------------------

      procedure Fill_Look_Aheads (Look_Aheads : in out Terminal_Offset_Map) is

         procedure Add
           (Added      : in out Tools.Terminal_Set_Indexed_By_Non_Terminal;
            State      : State_Index;
            Prod       : Production_Index;
            Next       : Part_Index;
            Look_Ahead : Terminal_Set);

         Source_State  : LR.State_Index := 1;
         Source_Index  : LR_Item_Index := 1;

         To_Do       : Offset_Set := (others => False);
         To_Do_Count : Natural;

         ---------
         -- Add --
         ---------

         procedure Add
           (Added      : in out Tools.Terminal_Set_Indexed_By_Non_Terminal;
            State      : State_Index;
            Prod       : Production_Index;
            Next       : Part_Index;
            Look_Ahead : Terminal_Set)
         is
            P   : Production renames Input.Production (Prod);
            R   : Reference;
            Old : Terminal_Set;
            Target_State  : LR.State_Index;
            Target_Index  : LR_Item_Index := LR_Item_Index'Last;
         begin
            if Next > P.Last then  --  A := α .
               return;
            end if;

            R := To_Reference (Input.Part (Next));
            Target_State := C.Go_To (R, State);

            for J in C.Ranges (Target_State).First
              .. C.Ranges (Target_State).Last
            loop
               if C.List (J) = To_Item (Next) then
                  Target_Index := J;
                  exit;
               end if;
            end loop;

            Old := Look_Aheads (Target_Index);

            Look_Aheads (Target_Index) := Look_Aheads (Target_Index)
              or Look_Ahead;

            if not To_Do (Target_Index) and then
              Old /= Look_Aheads (Target_Index)
            then
               To_Do (Target_Index) := True;
               To_Do_Count := To_Do_Count + 1;
            end if;

            --  A := α . B β
            if Input.Part (Next).Is_Non_Terminal_Reference then
               --  Add closure of kernel item
               declare
                  Set : Terminal_Set :=
                    Get_First (Next + 1, P.Last, Look_Ahead);
                  B : Non_Terminal renames
                    Input.Non_Terminal (Input.Part (Next).Denote);
               begin
                  if Check_Added (Added, B.Index, Set) then
                     for P in B.First .. B.Last loop
                        Add
                          (Added,
                           State,
                           P,
                           Input.Production (P).First,
                           Set);
                     end loop;
                  end if;
               end;
            end if;
         end Add;

      begin
         Look_Aheads (Source_Index) (End_Of_File) := True;
         To_Do (Source_Index) := True;
         To_Do_Count := 1;

         while To_Do_Count > 0 loop
            declare
               Added : Tools.Terminal_Set_Indexed_By_Non_Terminal :=
                 (1 .. Input.Last_Non_Terminal =>
                    (0 .. Input.Last_Terminal => False));
            begin
               Next_To_Do_Item (To_Do, Source_State, Source_Index);
               To_Do (Source_Index) := False;
               To_Do_Count := To_Do_Count - 1;

               declare
                  Item : constant LR_Item := C.List (Source_Index);
                  Next : Part_Index;
                  Prod : constant Production_Index :=
                    To_Production (Input, Item);
               begin
                  if Item = 0 then
                     Next := Input.Production (Prod).First;
                  else
                     Next := Part_Index (Item + 1);
                  end if;

                  Add
                    (Added,
                     Source_State,
                     Prod,
                     Next,
                     Look_Aheads (Source_Index));
               end;
            end;
         end loop;
      end Fill_Look_Aheads;

      First  : Tools.Terminal_Set_Per_Non_Terminal
        (Input.Last_Terminal, Input.Last_Non_Terminal);
      --  FIRST (A) for each non-terminal A

      ---------------
      -- Get_First --
      ---------------

      function Get_First
        (From, To : Part_Index;     --  This is β
         Default  : Terminal_Set)   --  This is a
         return Terminal_Set        --  This is FIRST (βa)
      is
         Result : Terminal_Set := (others => False);
      begin
         for P of Input.Part (From .. To) loop
            if P.Is_Terminal_Reference then
               Result (P.Denote) := True;
               return Result;
            else  --  non terminal reference X
               for T in 1 .. Input.Last_Terminal loop
                  if First.Map (P.Denote, T) then  --  Append FIRST(X)
                     Result (T) := True;
                  end if;
               end loop;

               if not First.Map (P.Denote, Tools.ε) then
                  return Result;
               end if;

               --  Continue if ε ∈ FIRST(X)
            end if;
         end loop;

         Result := Result or Default;  --  Append a

         return Result;
      end Get_First;

      ---------------------
      -- Is_Right_Nulled --
      ---------------------

      function Is_Right_Nulled (From, To : Part_Index) return Boolean is
      begin
         if Right_Nulled then
            for P of Input.Part (From .. To) loop
               if P.Is_Terminal_Reference or else
                 not First.Map (P.Denote, Tools.ε)
               then
                  return False;
               end if;
            end loop;

            return True;
         else
            return False;
         end if;
      end Is_Right_Nulled;

      ---------------------
      -- Next_To_Do_Item --
      ---------------------

      procedure Next_To_Do_Item
        (To_Do   : Offset_Set;
         State   : in out LR.State_Index;
         Offset  : in out LR_Item_Index) is
      begin
         for J in To_Do'Range loop
            if To_Do (Offset) then
               return;
            elsif Offset = To_Do'Last then
               State := 1;
               Offset := To_Do'First;
            elsif C.Ranges (State).Last = Offset then
               State := State + 1;
               Offset := C.Ranges (State).First;
            else
               Offset := Offset + 1;
            end if;
         end loop;
      end Next_To_Do_Item;

      Look_Aheads : Terminal_Offset_Map := (others => (others => False));
      --  Look ahead terminals for each LR_Item in any state

      Result : LR_Tables.Table := LR_Tables.Create
        (Last_State        => C.Last_State,
         Last_Terminal     => Input.Last_Terminal,
         Last_Non_Terminal => Input.Last_Non_Terminal);


   begin
      Tools.Get_First (Input, First);

      Fill_Look_Aheads (Look_Aheads);

      for State in 1 .. C.Last_State loop
         declare
            Target  : State_Count;
            Set     : constant LR_Item_Set := To_Set (C, State);
            Added   : Tools.Terminal_Set_Indexed_By_Non_Terminal :=
              (1 .. Input.Last_Non_Terminal =>
                 (0 .. Input.Last_Terminal => False));
         begin
            for J in Set'Range loop
               declare
                  Item : constant LR_Item := Set (J);
                  Next : Part_Index;
                  Prod : constant Production_Index :=
                    To_Production (Input, Item);
               begin
                  if Item = 0 then
                     Next := Input.Production (Prod).First;
                  else
                     Next := Part_Index (Item + 1);
                  end if;

                  Add_Recuces
                    (Result, Added, State, Prod, Next, Look_Aheads (J));
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

      Free (C);
      return Result;
   end Build;

end Gela.Grammars.LR.LALR;
