--  Check conflict resolution

with Gela.Grammars;
with Gela.Grammars.Conflicts;
with Gela.Grammars.Constructors;
with Gela.Grammars_Debug;
with Gela.Grammars.Reader;
with Gela.Grammars.LR_Tables;
with Gela.Grammars.LR.Simple;

with Ada.Text_IO;

procedure TS_00023 is

   procedure Print_Action
     (Table : Gela.Grammars.LR_Tables.Table;
      State : Gela.Grammars.LR.State_Index;
      T     : Gela.Grammars.Terminal_Count);

   ------------------
   -- Print_Action --
   ------------------

   procedure Print_Action
     (Table : Gela.Grammars.LR_Tables.Table;
      State : Gela.Grammars.LR.State_Index;
      T     : Gela.Grammars.Terminal_Count)
   is
      use Gela.Grammars.LR_Tables;
      use type Gela.Grammars.Terminal_Count;
      use type Gela.Grammars.LR.State_Count;

      S : constant Gela.Grammars.LR.State_Count :=
        Shift (Table, State, T);
      R : constant Reduce_Iterator := Reduce (Table, State, T);
   begin
      Ada.Text_IO.Put (' ');

      if T = 0  and then Finish (Table, State) then
         Ada.Text_IO.Put ("FINISH   ");
      elsif S /= 0 then
         Ada.Text_IO.Put ("SHIFT ");
         Ada.Text_IO.Put (Gela.Grammars.LR.State_Count'Image (S));

         if S in 1 .. 9 then
            Ada.Text_IO.Put (' ');
         end if;
      elsif not Is_Empty (R) then
         Ada.Text_IO.Put ("REDUCE");

         Ada.Text_IO.Put
           (Gela.Grammars.Production_Index'Image (Production (R)));

         if Production (R) in 1 .. 9 then
            Ada.Text_IO.Put (' ');
         end if;
      else
         Ada.Text_IO.Put ("Error    ");
      end if;
   end Print_Action;

   G : constant Gela.Grammars.Grammar := Gela.Grammars.Reader.Read ("test.ag");
   AG : constant Gela.Grammars.Grammar :=
     Gela.Grammars.Constructors.To_Augmented (G);
   use Gela.Grammars;
begin
   --  Gela.Grammars_Debug.Print (AG);

   declare
      use Gela.Grammars.LR;

      Table : LR_Tables.Table_Access := Simple.Build (AG);
      R : Gela.Grammars.Conflicts.Resolver;
   begin
      R.Resolve (AG, Table.all);
      Gela.Grammars_Debug.Print_Conflicts (AG, Table.all);

      for S in 1 .. LR_Tables.Last_State (Table.all) loop
         Ada.Text_IO.Put (State_Index'Image (S));

         if S <= 9 then
            Ada.Text_IO.Put (' ');
         end if;

         for T in 0 .. AG.Last_Terminal loop
            Print_Action (Table.all, S, T);
         end loop;

         Ada.Text_IO.Put (ASCII.HT);

         for NT in 1 .. AG.Last_Non_Terminal loop
            Ada.Text_IO.Put
              (State_Count'Image (LR_Tables.Shift (Table.all, S, NT)));
         end loop;

         Ada.Text_IO.New_Line;
      end loop;

      LR_Tables.Free (Table);
   end;
end TS_00023;
