------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Ada.Containers.Vectors;
with Ada.Unchecked_Deallocation;

with Gela.Grammars.LR;

package body Gela.Grammars.RNGLR is

   --  This implementation is after "Right Nulled GLR Parsers" article.
   --  All one letter identifiers are kept original

   package Graph_Structured_Stacks is

      --  Graph Structured Stack contains node connected by (directional) edges
      --  Each node has associated State.
      --  Each edge has associated Data, or several alternatives of Data,
      --  which just special kind of Data node.
      --  Instead of Top node, Stack has set of node (see type Node_Set).
      --  Each Node_Set should be reased afteer use by Release call to avoid
      --  memory leak

      type GSS is tagged private;
      type Node is private;
      type Edge is private;
      type Node_Set is private;

      function New_Node_Set (Self : in out GSS) return Node_Set;
      --  Create empty set of nodes

      function New_Node_Set
        (Self  : in out GSS;
         State : LR.State_Index) return Node_Set;
      --  Create set of nodes and initialize it with single Node of given State

      procedure New_Edge
        (Self  : in out GSS;
         From  : in out Node;
         To    : Node;
         Data  : AST_Nodes.Node_Access);
      --  Create edge From a node To a node, attach Data to new edge

      function New_Node_And_Edge
        (Self  : in out GSS;
         Set   : in out Node_Set;
         State : LR.State_Index;
         To    : Node;
         Data  : AST_Nodes.Node_Access) return Node;
      --  Create node with given State in given node Set, then
      --  create edge from new node To a node, attach Data to new edge

      function First (Set : Node_Set) return Node;
      --  Get first note in the Set
      function Get_Node (Set : Node_Set; State : LR.State_Index) return Node;
      --  Get node with given State from Set or null if none
      function Is_Null (X : Node_Set) return Boolean;
      --  Check is set is empty
      procedure Release (X : Node_Set);
      --  Deallocate unused set

      function Is_Null (X : Node) return Boolean;
      --  Check is node is empty
      function First (X : Node) return Edge;
      --  Get first edge from a node
      function State (X : Node) return LR.State_Index;
      --  Get state of node
      function Get_Edge (From, To : Node) return Edge;
      --  Find edge between two nodes
      procedure Next_In_Set (X : in out Node);
      --  Go to next node is a set

      function Is_Null (X : Edge) return Boolean;
      --  Check is edge is empty
      --  function From (X : Edge) return Node;
      function To (X : Edge) return Node;
      --  Return node pointed by edge
      function Next (X : Edge) return Edge;
      --  Go to next edge is a node
      function To_First (X : Edge) return Edge;
      --  Short cut for First (To (X))
      function Data (X : Edge) return AST_Nodes.Node_Access;
      --  Get data attached to edge

      procedure Append_Data
        (X    : Edge;
         NT   : Non_Terminal_Count;
         F    : AST_Nodes.Node_Fabric'Class;
         Data : AST_Nodes.Node_Access);
      --  Append alternative data to edge X

   private
      type Edge_Node;
      type Internal_Node;
      type Node is access all Internal_Node;
      type Edge is access all Edge_Node;

      type Edge_Node is record
         Data  : AST_Nodes.Node_Access;
         Count : Positive;
         Up    : Node;
         Next  : Edge;  --  Next in Node
      end record;

      type Internal_Node is record
         State : LR.State_Index;
         Refs  : Positive;
         First : Edge;
         Next  : Node;  --  Next in Node_Set
      end record;

      type Node_Set is record
         First : Node;
      end record;

      type GSS is tagged record
         null;
      end record;

      procedure Release (X : in out Node);
   end Graph_Structured_Stacks;

   package body Graph_Structured_Stacks is

      ------------------
      -- New_Node_Set --
      ------------------

      function New_Node_Set
        (Self  : in out GSS;
         State : LR.State_Index) return Node_Set
      is
         pragma Unreferenced (Self);
      begin
         return (First => new Internal_Node'(State => State,
                                             Refs  => 1,
                                             Next  => null,
                                             First => new Edge_Node'
                                               (Data  => null,
                                                Count => 1,
                                                Up    => null,
                                                Next  => null)));
      end New_Node_Set;

      ------------------
      -- New_Node_Set --
      ------------------

      function New_Node_Set (Self : in out GSS) return Node_Set is
         pragma Unreferenced (Self);
      begin
         return (First => null);
      end New_Node_Set;

      --------------
      -- New_Edge --
      --------------

      procedure New_Edge
        (Self  : in out GSS;
         From  : in out Node;
         To    : Node;
         Data  : AST_Nodes.Node_Access) is
         pragma Unreferenced (Self);
      begin
         To.Refs := To.Refs + 1;
         From.First := new Edge_Node'(Data  => Data,
                                      Count => 1,
                                      Up    => To,
                                      Next  => From.First);
      end New_Edge;

      -----------------------
      -- New_Node_And_Edge --
      -----------------------

      function New_Node_And_Edge
        (Self  : in out GSS;
         Set   : in out Node_Set;
         State : LR.State_Index;
         To    : Node;
         Data  : AST_Nodes.Node_Access) return Node is
         pragma Unreferenced (Self);
      begin
         To.Refs := To.Refs + 1;
         Set.First := new Internal_Node'(State => State,
                                         Refs  => 1,
                                         Next  => Set.First,
                                         First => new Edge_Node'
                                           (Data  => Data,
                                            Count => 1,
                                            Up    => To,
                                            Next  => null));

         return Set.First;
      end New_Node_And_Edge;

      -----------
      -- First --
      -----------

      function First (Set : Node_Set) return Node is
      begin
         return Set.First;
      end First;

      --------------
      -- Get_Node --
      --------------

      function Get_Node (Set : Node_Set; State : LR.State_Index) return Node is
         use type LR.State_Index;
         Item : Node := First (Set);
      begin
         while not Is_Null (Item) and then Item.State /= State loop
            Next_In_Set (Item);
         end loop;

         return Item;
      end Get_Node;

      -------------
      -- Is_Null --
      -------------

      function Is_Null (X : Node_Set) return Boolean is
      begin
         return X.First = null;
      end Is_Null;

      -------------
      -- Is_Null --
      -------------

      function Is_Null (X : Node) return Boolean is
      begin
         return X = null;
      end Is_Null;

      -----------
      -- First --
      -----------

      function First (X : Node) return Edge is
      begin
         return X.First;
      end First;

      -------------
      -- Release --
      -------------

      procedure Release (X : Node_Set) is
         Item, Prev : Node := X.First;
      begin
         while Item /= null loop
            Prev := Item;
            Item := Item.Next;
            Release (Prev);
         end loop;
      end Release;

      -------------
      -- Release --
      -------------

      procedure Release (X : in out Node) is
         use type Gela.Grammars.AST_Nodes.Node_Access;
         procedure Free is
           new Ada.Unchecked_Deallocation (Internal_Node, Node);
         procedure Free is new Ada.Unchecked_Deallocation (Edge_Node, Edge);
      begin
         if X = null then
            return;
         elsif X.Refs = 1 then
            declare
               Prev : Edge;
               Item : Edge := X.First;
            begin
               while Item /= null loop
                  Release (Item.Up);

                  if Item.Data /= null then
                     Item.Data.Reference (-1);
                  end if;

                  Prev := Item;
                  Item := Item.Next;

                  Free (Prev);
               end loop;

               Free (X);
            end;
         else
            X.Refs := X.Refs - 1;
         end if;
      end Release;

      -----------
      -- State --
      -----------

      function State (X : Node) return LR.State_Index is
      begin
         return X.State;
      end State;

      --------------
      -- Get_Edge --
      --------------

      function Get_Edge (From, To : Node) return Edge is
         use type LR.State_Index;
         Item : Edge := First (From);
      begin
         while Item /= null loop
            if Item.Up = To then
               return Item;
            end if;

            Item := Next (Item);
         end loop;

         return null;
      end Get_Edge;

      -----------------
      -- Next_In_Set --
      -----------------

      procedure Next_In_Set (X : in out Node) is
      begin
         X := X.Next;
      end Next_In_Set;

      -------------
      -- Is_Null --
      -------------

      function Is_Null (X : Edge) return Boolean is
      begin
         return X = null;
      end Is_Null;

      --------
      -- To --
      --------

      function To (X : Edge) return Node is
      begin
         return X.Up;
      end To;

      ----------
      -- Next --
      ----------

      function Next (X : Edge) return Edge is
      begin
         return X.Next;
      end Next;

      --------------
      -- To_First --
      --------------

      function To_First (X : Edge) return Edge is
      begin
         return First (X.Up);
      end To_First;

      ---------------
      -- Data --
      ---------------

      function Data (X : Edge) return AST_Nodes.Node_Access is
      begin
         return X.Data;
      end Data;

      -----------------
      -- Append_Data --
      -----------------

      procedure Append_Data
        (X    : Edge;
         NT   : Non_Terminal_Count;
         F    : AST_Nodes.Node_Fabric'Class;
         Data : AST_Nodes.Node_Access) is
      begin
         if X.Count = 1 then
            declare
               Result : constant AST_Nodes.Node_Access
                 := F.New_Alternative (NT);
            begin
               Result.Set_Child (1, X.Data);
               X.Data.Reference (-1);
               Result.Set_Child (2, Data);
               Data.Reference (-1);
               X.Data := Result;
            end;
         else
            X.Data.Set_Child (X.Count + 1, Data);
         end if;

         X.Count := X.Count + 1;
      end Append_Data;

   end Graph_Structured_Stacks;

   package Stacks renames Graph_Structured_Stacks;

   type R_Node is record
      V         : Stacks.Node;
      Node      : AST_Nodes.Node_Access;
      Reduction : LR_Tables.Reduce_Iterator;
      M         : Natural;
   end record;

   package R_Vectors is new Ada.Containers.Vectors (Positive, R_Node);

   type Q_Node is record
      V : Stacks.Node;
      K : LR.State_Index;
   end record;

   package Q_Vectors is new Ada.Containers.Vectors (Positive, Q_Node);

   -----------
   -- Parse --
   -----------

   procedure Parse
     (G : Grammar;
      T : LR_Tables.Table;
      F : AST_Nodes.Node_Fabric'Class;
      L : in out Lexer'Class;
      Tree : out AST_Nodes.Node_Access)
   is
      use type LR.State_Index;
      procedure Reducer;
      procedure Shifter;

      R     : R_Vectors.Vector;      --  R
      Q     : Q_Vectors.Vector;      --  Q

      Initial_State : constant LR.State_Index := 1;
      Stack : Stacks.GSS;

      A1 : constant Terminal_Count := L.Next;
      Ui : Stacks.Node_Set := Stack.New_Node_Set (Initial_State);
      --  U0 = { V0 }
      V0 : constant Stacks.Node := Stacks.First (Ui);
      Ai : Terminal_Count;  --  a (i+1)
      An : Terminal_Count;  --  a (i+2)

      -------------
      -- Reducer --
      -------------

      procedure Reducer is
         function Find (Node : in out Stacks.Node) return Boolean;
         --  Find next node at level Item.M-1 using Path as iteration state
         function New_Node return AST_Nodes.Node_Access;
         --  Create new node and set children nodes to it

         Item   : constant R_Node := R.First_Element;
         Prod   : Production renames G.Production
           (LR_Tables.Production (Item.Reduction));
         X      : constant Non_Terminal_Index := Prod.Parent;
         Length : constant Natural := Natural'Max (0, Item.M - 1);
         Path   : array (1 .. Length) of Stacks.Edge;

         ----------
         -- Find --
         ----------

         function Find (Node : in out Stacks.Node) return Boolean is
            function Find_First (From : Positive) return Boolean;

            ----------------
            -- Find_First --
            ----------------

            function Find_First (From : Positive) return Boolean is
            begin
               for J in From .. Path'Last loop
                  Path (J) := Stacks.To_First (Path (J - 1));

                  if Stacks.Is_Null (Path (J)) then
                     return False;
                  end if;
               end loop;

               return True;
            end Find_First;
         begin
            if Stacks.Is_Null (Node) then
               if Length = 0 then
                  Node := Item.V;
                  return True;
               end if;

               Path (1) := Stacks.First (Item.V);

               if Find_First (2) then
                  Node := Stacks.To (Path (Path'Last));
                  return True;
               else
                  return False;
               end if;
            elsif Length = 0 then
               return False;
            end if;

            for J in reverse 1 .. Path'Last loop
               while not Stacks.Is_Null (Stacks.Next (Path (J)))
               loop
                  Path (J) := Stacks.Next (Path (J));

                  if Find_First (J + 1) then
                     Node := Stacks.To (Path (Path'Last));
                     return True;
                  end if;
               end loop;
            end loop;

            return False;
         end Find;

         --------------
         -- New_Node --
         --------------

         function New_Node return AST_Nodes.Node_Access is
            Result : constant AST_Nodes.Node_Access := F.New_Node (Prod.Index);
            Index  : Positive := 1;
         begin
            if Item.M = 0 then
               return Result;
            end if;

            for J in reverse 1 .. Item.M - 1 loop
               Result.Set_Child (Index, Stacks.Data (Path (J)));
               Index := Index + 1;
            end loop;

            Result.Set_Child (Index, Item.Node);

            return Result;
         end New_Node;

         U      : Stacks.Node;

      begin
         R.Delete_First;

         while Find (U) loop
            declare
               Node : constant AST_Nodes.Node_Access := New_Node;
               Edge : Graph_Structured_Stacks.Edge;
               K : constant LR.State_Index := Stacks.State (U);
               L : constant LR.State_Index := LR_Tables.Shift (T, K, X);
               W : Graph_Structured_Stacks.Node := Stacks.Get_Node (Ui, L);
            begin
               if not Stacks.Is_Null (W) then
                  Edge := Stacks.Get_Edge (W, U);

                  if Stacks.Is_Null (Edge) then
                     Stack.New_Edge
                       (From  => W,
                        To    => U,
                        Data  => Node);

                     if Item.M /= 0 then
                        declare
                           Z : LR_Tables.Reduce_Iterator :=
                             LR_Tables.Reduce (T, L, Ai);
                           P : Part_Count;
                        begin
                           while not LR_Tables.Is_Empty (Z) loop
                              P := LR_Tables.Part (Z) + 1 -
                                G.Production (LR_Tables.Production (Z)).First;

                              if P > 0 then
                                 R.Append ((U, Node, Z, Positive (P)));
                              end if;

                              LR_Tables.Next (T, Z);
                           end loop;
                        end;
                     end if;
                  else
                     Stacks.Append_Data (Edge, X, F, Node);
                  end if;
               else
                  W := Stack.New_Node_And_Edge
                    (Set   => Ui,
                     State => L,
                     To    => U,
                     Data  => Node);

                  declare
                     H : constant LR.State_Count := LR_Tables.Shift (T, L, Ai);
                  begin
                     if H /= 0 then
                        Q.Append ((W, H));
                     end if;
                  end;

                  declare
                     Z : LR_Tables.Reduce_Iterator :=
                       LR_Tables.Reduce (T, L, Ai);
                     P : Part_Count;
                  begin
                     while not LR_Tables.Is_Empty (Z) loop
                        P := LR_Tables.Part (Z) + 1 -
                          G.Production (LR_Tables.Production (Z)).First;

                        if P = 0 then
                           R.Append ((W, null, Z, 0));
                        elsif Item.M /= 0 then
                           R.Append ((U, Node, Z, Positive (P)));
                        end if;

                        LR_Tables.Next (T, Z);
                     end loop;
                  end;
               end if;
            end;
         end loop;
      end Reducer;

      -------------
      -- Shifter --
      -------------

      procedure Shifter is
         Un : Stacks.Node_Set := Stack.New_Node_Set;
         Qn : Q_Vectors.Vector;  --  Q'
         Node_N : constant AST_Nodes.Node_Access := F.New_Token;  --  Ai
         Count  : Positive := 1;  --  Reuse count for Node_N
      begin
         for Item of Q loop
            declare
               V : constant Stacks.Node := Item.V;
               K : constant LR.State_Index := Item.K;
               W : Stacks.Node := Stacks.Get_Node (Un, K);
            begin
               if not Stacks.Is_Null (W) then
                  Stack.New_Edge
                    (From  => W,
                     To    => V,
                     Data  => Node_N);

                  if Count > 1 then
                     Node_N.Reference;
                  end if;

                  declare
                     Z : LR_Tables.Reduce_Iterator :=
                       LR_Tables.Reduce (T, K, An);
                     P : Part_Count;
                  begin
                     while not LR_Tables.Is_Empty (Z) loop
                        P := LR_Tables.Part (Z) + 1 -
                          G.Production (LR_Tables.Production (Z)).First;

                        if P > 0 then
                           R.Append ((V, Node_N, Z, Positive (P)));
                        end if;

                        LR_Tables.Next (T, Z);
                     end loop;
                  end;
               else
                  W := Stack.New_Node_And_Edge
                    (Set   => Un,
                     State => K,
                     To    => V,
                     Data  => Node_N);

                  if Count > 1 then
                     Node_N.Reference;
                  end if;

                  declare
                     H : constant LR.State_Count := LR_Tables.Shift (T, K, An);
                  begin
                     if H /= 0 then
                        Qn.Append ((W, H));
                     end if;
                  end;

                  declare
                     Z : LR_Tables.Reduce_Iterator :=
                       LR_Tables.Reduce (T, K, An);
                     P : Part_Count;
                  begin
                     while not LR_Tables.Is_Empty (Z) loop
                        P := LR_Tables.Part (Z) + 1 -
                          G.Production (LR_Tables.Production (Z)).First;

                        if P = 0 then
                           R.Append ((W, null, Z, 0));
                        else
                           R.Append ((V, Node_N, Z, Positive (P)));
                        end if;

                        LR_Tables.Next (T, Z);
                     end loop;
                  end;
               end if;
            end;

            Count := Count + 1;
         end loop;

         Q := Qn;
         Stacks.Release (Ui);
         Ui := Un;
      end Shifter;

   begin
      declare
         K : constant LR.State_Count := LR_Tables.Shift (T, Initial_State, A1);
      begin
         if K /= 0 then
            Q.Append ((V0, K));
         end if;
      end;

      declare
         R1 : LR_Tables.Reduce_Iterator :=
           LR_Tables.Reduce (T, Initial_State, A1);
         P  : Part_Count;
      begin
         while not LR_Tables.Is_Empty (R1) loop
            P := LR_Tables.Part (R1) + 1 -
              G.Production (LR_Tables.Production (R1)).First;

            if P = 0 then
               R.Append ((V0, null, R1, 0));
            end if;

            LR_Tables.Next (T, R1);
         end loop;
      end;

      An := A1;

      loop
         Ai := An;

         if Stacks.Is_Null (Ui) then
            raise Constraint_Error;
         end if;

         while not R.Is_Empty loop
            Reducer;
         end loop;

         if Ai /= 0 then
            An := L.Next;
            Shifter;
         end if;

         exit when Ai = 0;
      end loop;

      declare
         U : Stacks.Node := Stacks.First (Ui);
      begin
         while not Stacks.Is_Null (U) loop
            if LR_Tables.Finish (T, Stacks.State (U)) then
               Tree := Stacks.Data (Stacks.First (U));
               Tree.Reference;
               exit;
            end if;

            Stacks.Next_In_Set (U);
         end loop;

         Stacks.Release (Ui);
      end;

   end Parse;

end Gela.Grammars.RNGLR;
