--  Check GLR parser

with Ada.Text_IO;
with Ada.Containers.Doubly_Linked_Lists;
with Ada.Wide_Text_IO;

with AST; use AST;

with Anagram.Grammars;
with Anagram.Grammars.Constructors;
with Anagram.Grammars_Convertors;
with Anagram.Grammars_Debug;
with Anagram.Grammars.Reader;
with Anagram.Grammars.LR_Tables;
with Anagram.Grammars.LR.LALR;
with Anagram.Grammars.RNGLR;
with Anagram.Grammars.Lexers;

procedure TS_00022 is

   procedure Print_Action
     (Table : Anagram.Grammars.LR_Tables.Table;
      State : Anagram.Grammars.LR.State_Index;
      T     : Anagram.Grammars.Terminal_Count);

   package Node_Lists is new Ada.Containers.Doubly_Linked_Lists
     (AST.Node_Access);

   procedure Print_Tree
     (Printed : in out Node_Lists.List;
      Tree    : AST.Node_Access;
      Input   : Anagram.Grammars.Grammar;
      Prefix  : Wide_Wide_String := "");

   package RNGLR is new Anagram.Grammars.RNGLR
     (AST.Node_Access, null, AST.Node_Fabric);

   type Lexer is new Anagram.Grammars.Lexers.Lexer with null record;
   function Next (Self : in out Lexer) return Anagram.Grammars.Terminal_Count;

   Last : Natural := 0;
   --  Token list for "2 * 2 + 2"
   List : constant
     array (Positive range <>) of Anagram.Grammars.Terminal_Count :=
     (1,   --  int
      3,   --  star
      1,   --  int
      2,   --  plus
      1,   --  int
      0);  --  EOF

   ----------
   -- Next --
   ----------

   function Next (Self : in out Lexer)
     return Anagram.Grammars.Terminal_Count
   is
      pragma Unreferenced (Self);
   begin
      Last := Last + 1;
      return List (Last);
   end Next;

   ------------------
   -- Print_Action --
   ------------------

   procedure Print_Action
     (Table : Anagram.Grammars.LR_Tables.Table;
      State : Anagram.Grammars.LR.State_Index;
      T     : Anagram.Grammars.Terminal_Count)
   is
      use Anagram.Grammars.LR_Tables;
      use type Anagram.Grammars.Terminal_Count;
      use type Anagram.Grammars.LR.State_Count;

      S : constant Anagram.Grammars.LR.State_Count :=
        Shift (Table, State, T);
      R : Reduce_Iterator := Reduce (Table, State, T);
   begin
      Ada.Text_IO.Put (' ');

      if T = 0  and then Finish (Table, State) then
         Ada.Text_IO.Put ("FINISH   ");
      end if;

      if S /= 0 then
         Ada.Text_IO.Put ("SHIFT ");
         Ada.Text_IO.Put (Anagram.Grammars.LR.State_Count'Image (S));

         if S in 1 .. 9 then
            Ada.Text_IO.Put (' ');
         end if;
      end if;

      if not Is_Empty (R) then
         Ada.Text_IO.Put ("REDU");
         while not Is_Empty (R) loop
            Ada.Text_IO.Put
              (Anagram.Grammars.Production_Index'Image (Production (R)));

            Ada.Text_IO.Put
              (Anagram.Grammars.Part_Index'Image (Part (R)));

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
      Tree    : AST.Node_Access;
      Input   : Anagram.Grammars.Grammar;
      Prefix  : Wide_Wide_String := "")
   is
      Node : constant AST.Node := Tree.all;
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
            AST.Print (Child.all, Input);
         end if;
      end loop;
      Ada.Wide_Text_IO.Put_Line (" ]");

      for Child of Node.Children loop
         if Child /= null then
            Print_Tree (Printed, Child, Input, Prefix & "  ");
         end if;
      end loop;
   end Print_Tree;

   Fabric : aliased AST.Node_Fabric;

   X : constant Anagram.Grammars.Grammar :=
     Anagram.Grammars.Reader.Read ("test.ag");
   G : constant Anagram.Grammars.Grammar :=
     Anagram.Grammars_Convertors.Convert_With_Empty (X);
   AG : constant Anagram.Grammars.Grammar :=
     Anagram.Grammars.Constructors.To_Augmented (G);
   use Anagram.Grammars;
begin
--   Anagram.Grammars.AYACC.Write (Plain);
   Anagram.Grammars_Debug.Print (AG);
   Ada.Text_IO.Put ("Terminals" & Terminal_Count'Image (G.Last_Terminal));
   Ada.Text_IO.Put
     (" Non_Terminals" & Non_Terminal_Count'Image (G.Last_Non_Terminal));
   Ada.Text_IO.Put
     (" Production" & Production_Count'Image (G.Last_Production));
   Ada.Text_IO.Put_Line (" Parts" & Part_Count'Image (G.Last_Part));

   declare
      use Anagram.Grammars.LR;

      Table   : LR_Tables.Table_Access := LALR.Build (AG, True);
      Tree    : AST.Node_Access;
      Printed : Node_Lists.List;
      L       : Lexer;
   begin
      Ada.Text_IO.Put_Line
        ("Last_State=" & State_Index'Image (LR_Tables.Last_State (Table.all)));

      Anagram.Grammars_Debug.Print_Conflicts (AG, Table.all);

      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("Table:");

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

      RNGLR.Parse
        (G => AG, T => Table.all, L => L, F => Fabric'Access, Tree => Tree);

      Ada.Text_IO.New_Line;
      Ada.Text_IO.Put_Line ("Print Tree:");
      Print_Tree (Printed, Tree, G);
      AST.Dereference (Fabric'Access, Tree);

      LR_Tables.Free (Table);
   end;
end TS_00022;
