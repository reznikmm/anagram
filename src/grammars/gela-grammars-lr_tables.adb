package body Gela.Grammars.LR_Tables is

   --------------
   -- Is_Empty --
   --------------

   function Is_Empty (Self : Reduce_Iterator) return Boolean is
   begin
      return Self.Production = 0;
   end Is_Empty;

   ----------------
   -- Last_State --
   ----------------

   function Last_State (Self : Table) return LR.State_Index is
   begin
      return Self.Last_State;
   end Last_State;

   ----------
   -- Part --
   ----------

   function Part (Self : Reduce_Iterator) return Part_Count is
   begin
      return Self.Part;
   end Part;

   ----------------
   -- Production --
   ----------------

   function Production (Self : Reduce_Iterator) return Production_Index is
   begin
      return Self.Production;
   end Production;

   ----------
   -- Next --
   ----------

   procedure Next
     (Self : Table;
      Item : in out Reduce_Iterator)
   is
   begin
      if Item.Next = 0 then
         Item.Production := 0;
      else
         Item := Self.Reduce_Vector (Item.Next);
      end if;
   end Next;

   ------------
   -- Create --
   ------------

   function Create
     (Last_State        : LR.State_Index;
      Last_Terminal     : Terminal_Index;
      Last_Non_Terminal : Non_Terminal_Index) return Table_Access is
   begin
      return new Table'(Last_State,
                        Last_Terminal,
                        Last_Non_Terminal,
                        Reduce_Vector => <>,
                        T_Shift  => (others => (others => 0)),
                        T_Finish => (others => False),
                        T_Reduce => (others => (others => 0)),
                        NT_Shift => (others => (others => 0)));
   end Create;

   -----------
   -- Shift --
   -----------

   function Shift
     (Self  : Table;
      State : LR.State_Index;
      NT    : Non_Terminal_Index)
      return LR.State_Count is
   begin
      return Self.NT_Shift (State, NT);
   end Shift;

   -----------
   -- Shift --
   -----------

   function Shift
     (Self  : Table;
      State : LR.State_Index;
      T     : Terminal_Count)
      return LR.State_Count is
   begin
      return Self.T_Shift (State, T);
   end Shift;

   ------------
   -- Reduce --
   ------------

   function Reduce
     (Self  : Table;
      State : LR.State_Index;
      T     : Terminal_Count)
      return Reduce_Iterator
   is
      Index : constant Natural := Self.T_Reduce (State, T);
   begin
      if Index = 0 then
         return (0, 0, 0);
      else
         return Self.Reduce_Vector (Index);
      end if;
   end Reduce;

   -------------------
   -- Remove_Reduce --
   -------------------

   procedure Remove_Reduce
     (Self  : in out Table;
      State : LR.State_Index;
      T     : Terminal_Count;
      Value : Production_Index)
   is
      Index : Natural := Self.T_Reduce (State, T);
      Next  : Natural := Self.Reduce_Vector (Index).Next;
   begin
      if Self.Reduce_Vector (Index).Production = Value then
         Self.T_Reduce (State, T) := Next;
         return;
      end if;

      while Self.Reduce_Vector (Next).Production /= Value loop
         Index := Next;
         Next := Self.Reduce_Vector (Index).Next;
      end loop;

      Self.Reduce_Vector (Index).Next := Self.Reduce_Vector (Next).Next;
   end Remove_Reduce;

   ------------------
   -- Remove_Shift --
   ------------------

   procedure Remove_Shift
     (Self  : in out Table;
      State : LR.State_Index;
      T     : Terminal_Count) is
   begin
      Self.T_Shift (State, T) := 0;
   end Remove_Shift;

   ------------
   -- Finish --
   ------------

   function Finish
     (Self  : Table;
      State : LR.State_Index)
      return Boolean is
   begin
      return Self.T_Finish (State);
   end Finish;

   ---------------
   -- Set_Shift --
   ---------------

   procedure Set_Shift
     (Self  : in out Table;
      State : LR.State_Index;
      NT    : Non_Terminal_Index;
      Value : LR.State_Index) is
   begin
      Self.NT_Shift (State, NT) := Value;
   end Set_Shift;

   ---------------
   -- Set_Shift --
   ---------------

   procedure Set_Shift
     (Self  : in out Table;
      State : LR.State_Index;
      T     : Terminal_Count;
      Value : LR.State_Index)
   is
   begin
      Self.T_Shift (State, T) := Value;
   end Set_Shift;

   ----------------
   -- Set_Reduce --
   ----------------

   procedure Set_Reduce
     (Self  : in out Table;
      State : LR.State_Index;
      T     : Terminal_Count;
      Value : Production_Index;
      Part  : Part_Count := 0)
   is
      Item : constant Reduce_Iterator :=
        (Value, Part, Self.T_Reduce (State, T));
   begin
      Self.Reduce_Vector.Append (Item);
      Self.T_Reduce (State, T) := Self.Reduce_Vector.Last_Index;
   end Set_Reduce;

   ----------------
   -- Set_Finish --
   ----------------

   procedure Set_Finish
     (Self  : in out Table;
      State : LR.State_Index) is
   begin
      Self.T_Finish (State) := True;
   end Set_Finish;

end Gela.Grammars.LR_Tables;
