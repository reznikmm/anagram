--  Check GLR parser

with Ada.Text_IO;
with Ada.Containers.Doubly_Linked_Lists;
with Ada.Wide_Text_IO;

with AST;

with Gela.Grammars;
with Gela.Grammars.Constructors;
with Gela.Grammars_Convertors;
with Gela.Grammars_Debug;
with Gela.Grammars.Reader;
with Gela.Grammars.LR_Tables;
with Gela.Grammars.LR.LALR;
with Gela.Grammars.RNGLR;

with Gela.Grammars.AST_Nodes;

procedure TS_00022 is

   procedure Print_Action
     (Table : Gela.Grammars.LR_Tables.Table;
      State : Gela.Grammars.LR.State_Index;
      T     : Gela.Grammars.Terminal_Count);

   package Node_Lists is new Ada.Containers.Doubly_Linked_Lists
     (Gela.Grammars.AST_Nodes.Node_Access, Gela.Grammars.AST_Nodes."=");

   procedure Print_Tree
     (Printed : in out Node_Lists.List;
      Tree    : Gela.Grammars.AST_Nodes.Node_Access;
      Input   : Gela.Grammars.Grammar;
      Prefix  : Wide_Wide_String := "");

   type Lexer is new Gela.Grammars.RNGLR.Lexer with null record;
   function Next (Self : in out Lexer) return Gela.Grammars.Terminal_Count;

   Last : Natural := 0;
   --  Token list for "2 * 2 + 2"
   List : constant array (Positive range <>) of Gela.Grammars.Terminal_Count :=
     (1,   --  int
      3,   --  star
      1,   --  int
      2,   --  plus
      1,   --  int
      0);  --  EOF

   ----------
   -- Next --
   ----------

   function Next (Self : in out Lexer) return Gela.Grammars.Terminal_Count is
      pragma Unreferenced (Self);
   begin
      Last := Last + 1;
      return List (Last);
   end Next;

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
      R : Reduce_Iterator := Reduce (Table, State, T);
   begin
      Ada.Text_IO.Put (' ');

      if T = 0  and then Finish (Table, State) then
         Ada.Text_IO.Put ("FINISH   ");
      end if;

      if S /= 0 then
         Ada.Text_IO.Put ("SHIFT ");
         Ada.Text_IO.Put (Gela.Grammars.LR.State_Count'Image (S));

         if S in 1 .. 9 then
            Ada.Text_IO.Put (' ');
         end if;
      end if;

      if not Is_Empty (R) then
         Ada.Text_IO.Put ("REDU");
         while not Is_Empty (R) loop
            Ada.Text_IO.Put
              (Gela.Grammars.Production_Index'Image (Production (R)));

            Ada.Text_IO.Put
              (Gela.Grammars.Part_Index'Image (Part (R)));

            Next (Table, R);
         end loop;
      else
         Ada.Text_IO.Put ("Error    ");
      end if;
   end Print_Action;

   ----------------
   -- Print_Tree --
   ----------------

   procedure Print_Tree
     (Printed : in out Node_Lists.List;
      Tree    : Gela.Grammars.AST_Nodes.Node_Access;
      Input   : Gela.Grammars.Grammar;
      Prefix  : Wide_Wide_String := "")
   is
      use type Gela.Grammars.AST_Nodes.Node_Access;
      Node : AST.Node renames AST.Node (Tree.all);
   begin
      if Printed.Contains (Tree) then
         return;
      else
         Printed.Append (Tree);
      end if;

      AST.Print (Node, Input);
      Ada.Wide_Text_IO.Put (" [");
      for Child of Node.Children loop
         if Child /= null then
            AST.Print (AST.Node (Child.all), Input);
         end if;
      end loop;
      Ada.Wide_Text_IO.Put_Line (" ]");

      for Child of Node.Children loop
         if Child /= null then
            Print_Tree (Printed, Child, Input, Prefix & "  ");
         end if;
      end loop;
   end Print_Tree;

   Fabric : AST.Node_Fabric;

   X : constant Gela.Grammars.Grammar := Gela.Grammars.Reader.Read ("test.ag");
   G : constant Gela.Grammars.Grammar :=
     Gela.Grammars_Convertors.Convert_With_Empty (X);
   AG : constant Gela.Grammars.Grammar :=
     Gela.Grammars.Constructors.To_Augmented (G);
   use Gela.Grammars;
begin
--   Gela.Grammars.AYACC.Write (Plain);
   Gela.Grammars_Debug.Print (AG);
   Ada.Text_IO.Put ("Terminals" & Terminal_Count'Image (G.Last_Terminal));
   Ada.Text_IO.Put
     (" Non_Terminals" & Non_Terminal_Count'Image (G.Last_Non_Terminal));
   Ada.Text_IO.Put
     (" Production" & Production_Count'Image (G.Last_Production));
   Ada.Text_IO.Put_Line (" Parts" & Part_Count'Image (G.Last_Part));

   declare
      use Gela.Grammars.LR;

      Table   : constant LR_Tables.Table := LALR.Build (AG, True);
      Tree    : Gela.Grammars.AST_Nodes.Node_Access;
      Printed : Node_Lists.List;
      L       : Lexer;
   begin
      Ada.Text_IO.Put_Line
        ("Last_State=" & State_Index'Image (LR_Tables.Last_State (Table)));

      Gela.Grammars_Debug.Print_Conflicts (AG, Table);

      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("Table:");

      for S in 1 .. LR_Tables.Last_State (Table) loop
         Ada.Text_IO.Put (State_Index'Image (S));

         if S <= 9 then
            Ada.Text_IO.Put (' ');
         end if;

         for T in 0 .. AG.Last_Terminal loop
            Print_Action (Table, S, T);
         end loop;

         Ada.Text_IO.Put (ASCII.HT);

         for NT in 1 .. AG.Last_Non_Terminal loop
            Ada.Text_IO.Put
              (State_Count'Image (LR_Tables.Shift (Table, S, NT)));
         end loop;

         Ada.Text_IO.New_Line;
      end loop;

      Gela.Grammars.RNGLR.Parse
        (G => AG, T => Table, L => L, F => Fabric, Tree => Tree);

      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("Print Tree:");
      Print_Tree (Printed, Tree, G);
      Tree.Reference (-1);
   end;
end TS_00022;
