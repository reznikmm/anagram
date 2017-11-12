--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Ada.Unchecked_Deallocation;
with System.Pool_Local;

with Anagram.Grammars.LR;

package body Anagram.Grammars.RNGLR is

   --  This implementation is after "Right Nulled GLR Parsers" article.
   --  All one letter identifiers are kept original

   package Graph_Structured_Stacks is

      --  Graph Structured Stack contains node connected by (directional) edges
      --  Each node has associated State.
      --  Each edge has associated Data, or several alternatives of Data,
      --  which just special kind of Data node.
      --  Instead of Top node, Stack has set of node (see type Node_Set).
      --  Each Node_Set should be released after use by Release call to avoid
      --  memory leak.
      --  Stack itself should be released after use by Release call to avoid
      --  memory leak.

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
         Data  : Node_Access);
      --  Create edge From a node To a node, attach Data to new edge

      function New_Node_And_Edge
        (Self  : in out GSS;
         Set   : in out Node_Set;
         State : LR.State_Index;
         To    : Node;
         Data  : Node_Access) return Node;
      --  Create node with given State in given node Set, then
      --  create edge from new node To a node, attach Data to new edge

      function First (Set : Node_Set) return Node;
      --  Get first note in the Set
      function Get_Node (Set : Node_Set; State : LR.State_Index) return Node;
      --  Get node with given State from Set or null if none
      function Is_Null (X : Node_Set) return Boolean;
      --  Check is set is empty
      procedure Release
        (Self : in out GSS;
         F    : access Node_Fabric;
         X    : Node_Set);
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
      function Data (X : Edge) return Node_Access;
      --  Get data attached to edge

      procedure Append_Data
        (X    : Edge;
         NT   : Non_Terminal_Count;
         F    : access Node_Fabric;
         Data : Node_Access);
      --  Append alternative data to edge X

      procedure Release (Self : in out GSS);
      --  Deallocate unused set
   private
      type Edge_Node;
      type Internal_Node;
      type Node is access all Internal_Node;
      type Edge is access all Edge_Node;

      type Edge_Node is record
         Data  : Node_Access;
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
         Free_Nodes : Node;
         Free_Edges : Edge;
      end record;

      procedure Release
        (Self : in out GSS;
         F    : access Node_Fabric;
         X    : in out Node);

      function New_Edge
        (Self : in out GSS;
         Data  : Node_Access;
         Count : Positive;
         Up    : Node;
         Next  : Edge) return Edge;

      function New_Node
        (Self : in out GSS;
         State : LR.State_Index;
         Refs  : Positive;
         First : Edge;
         Next  : Node) return Node;

   end Graph_Structured_Stacks;

   package body Graph_Structured_Stacks is

      --------------
      -- New_Edge --
      --------------

      function New_Edge
        (Self : in out GSS;
         Data  : Node_Access;
         Count : Positive;
         Up    : Node;
         Next  : Edge) return Edge
      is
         New_Edge : Edge := Self.Free_Edges;
      begin
         if New_Edge = null then
            New_Edge := new Edge_Node;
         else
            Self.Free_Edges := New_Edge.Next;
         end if;

         New_Edge.all := (Data  => Data,
                          Count => Count,
                          Up    => Up,
                          Next  => Next);

         return New_Edge;
      end New_Edge;

      --------------
      -- New_Node --
      --------------

      function New_Node
        (Self : in out GSS;
         State : LR.State_Index;
         Refs  : Positive;
         First : Edge;
         Next  : Node) return Node
      is
         New_Node : Node := Self.Free_Nodes;
      begin
         if New_Node = null then
            New_Node := new Internal_Node;
         else
            Self.Free_Nodes := New_Node.Next;
         end if;

         New_Node.all := (State => State,
                          Refs  => Refs,
                          Next  => Next,
                          First => First);

         return New_Node;
      end New_Node;

      ------------------
      -- New_Node_Set --
      ------------------

      function New_Node_Set
        (Self  : in out GSS;
         State : LR.State_Index) return Node_Set
      is
         New_Edge : Edge;
         New_Node : Node;
      begin
         New_Edge := Self.New_Edge (Data  => Null_Node,
                                    Count => 1,
                                    Up    => null,
                                    Next  => null);

         New_Node := Self.New_Node (State => State,
                                    Refs  => 1,
                                    Next  => null,
                                    First => New_Edge);

         return (First => New_Node);
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
         Data  : Node_Access) is
      begin
         To.Refs := To.Refs + 1;
         From.First := Self.New_Edge (Data  => Data,
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
         Data  : Node_Access) return Node
      is
         New_Edge : Edge;
      begin
         To.Refs := To.Refs + 1;

         New_Edge := Self.New_Edge (Data  => Data,
                                    Count => 1,
                                    Up    => To,
                                    Next  => null);

         Set.First := Self.New_Node (State => State,
                                     Refs  => 1,
                                     Next  => Set.First,
                                     First => New_Edge);

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

      procedure Release
        (Self : in out GSS;
         F    : access Node_Fabric;
         X    : Node_Set)
      is
         Item, Prev : Node := X.First;
      begin
         while Item /= null loop
            Prev := Item;
            Item := Item.Next;
            Release (Self, F, Prev);
         end loop;
      end Release;

      -------------
      -- Release --
      -------------

      procedure Release (Self : in out GSS) is
         procedure Free is
           new Ada.Unchecked_Deallocation (Internal_Node, Node);
         procedure Free is new Ada.Unchecked_Deallocation (Edge_Node, Edge);
      begin
         declare
            Prev : Node;
            Item : Node := Self.Free_Nodes;
         begin
            while Item /= null loop
               Prev := Item;
               Item := Item.Next;
               Free (Prev);
            end loop;
         end;

         declare
            Prev : Edge;
            Item : Edge := Self.Free_Edges;
         begin
            while Item /= null loop
               Prev := Item;
               Item := Item.Next;
               Free (Prev);
            end loop;
         end;
      end Release;

      -------------
      -- Release --
      -------------

      procedure Release
        (Self : in out GSS;
         F    : access Node_Fabric;
         X    : in out Node)
      is
      begin
         if X = null then
            return;
         elsif X.Refs = 1 then
            declare
               Prev : Edge;
               Item : Edge := X.First;
            begin
               while Item /= null loop
                  Release (Self, F, Item.Up);

                  if Item.Data /= Null_Node then
                     Dereference (F, Item.Data);
                  end if;

                  Prev := Item;
                  Item := Item.Next;

                  Prev.Next := Self.Free_Edges;
                  Self.Free_Edges := Prev;
               end loop;

               X.Next := Self.Free_Nodes;
               Self.Free_Nodes := X;
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

      function Data (X : Edge) return Node_Access is
      begin
         return X.Data;
      end Data;

      -----------------
      -- Append_Data --
      -----------------

      procedure Append_Data
        (X    : Edge;
         NT   : Non_Terminal_Count;
         F    : access Node_Fabric;
         Data : Node_Access) is
      begin
         if X.Count = 1 then
            declare
               Saved  : Node_Access := Data;
               Result : constant Node_Access
                 := New_Alternative (F, NT);
            begin
               Set_Child (F, Result, 1, X.Data);
               Dereference (F, X.Data);
               Set_Child (F, Result, 2, Saved);
               Dereference (F, Saved);
               X.Data := Result;
            end;
         else
            Set_Child (F, X.Data, X.Count + 1, Data);
         end if;

         X.Count := X.Count + 1;
      end Append_Data;

   end Graph_Structured_Stacks;

   package Stacks renames Graph_Structured_Stacks;

   -----------
   -- Parse --
   -----------

   procedure Parse
     (G : Grammar;
      T : LR_Tables.Table;
      F : access Node_Fabric;
      L : in out Anagram.Grammars.Lexers.Lexer'Class;
      Tree : out Node_Access)
   is
      use type LR.State_Index;
      procedure Reducer;
      procedure Shifter;

      Local_Pool : System.Pool_Local.Unbounded_Reclaim_Pool;

      type R_Node;
      type Q_Node;

      type R_Node_Access is access all R_Node
        with Storage_Pool => Local_Pool;

      type Q_Node_Access is access all Q_Node
        with Storage_Pool => Local_Pool;

      procedure Append_R
         (V         : Stacks.Node;
          Node      : Node_Access;
          Reduction : LR_Tables.Reduce_Iterator;
          M         : Natural;
          List      : in out R_Node_Access);
      --  Allocate and initialize new R_Node, Append it to List

      procedure Append_Q
         (V    : Stacks.Node;
          K    : LR.State_Index;
          List : in out Q_Node_Access);
      --  Allocate and initialize new Q_Node, Append it to List

      type R_Node is record
         V         : Stacks.Node;
         Node      : Node_Access;
         Reduction : LR_Tables.Reduce_Iterator;
         M         : Natural;
         Next      : R_Node_Access;
      end record;

      type Q_Node is record
         V    : Stacks.Node;
         K    : LR.State_Index;
         Next : Q_Node_Access;
      end record;

      Free_R : R_Node_Access;  --  Reuse list for R_Node
      Free_Q : Q_Node_Access;  --  Reuse list for Q_Node

      --------------
      -- Append_R --
      --------------

      procedure Append_R
         (V         : Stacks.Node;
          Node      : Node_Access;
          Reduction : LR_Tables.Reduce_Iterator;
          M         : Natural;
          List      : in out R_Node_Access)
      is
         Result : R_Node_Access;
      begin
         if Free_R = null then
            Result := new R_Node;
         else
            Result := Free_R;
            Free_R := Free_R.Next;
         end if;

         Result.all := (V, Node, Reduction, M, List);
         List := Result;
      end Append_R;

      --------------
      -- Append_Q --
      --------------

      procedure Append_Q
         (V    : Stacks.Node;
          K    : LR.State_Index;
          List : in out Q_Node_Access)
      is
         Result :  Q_Node_Access;
      begin
         if Free_Q = null then
            Result := new Q_Node;
         else
            Result := Free_Q;
            Free_Q := Free_Q.Next;
         end if;

         Result.all := (V, K, List);
         List := Result;
      end Append_Q;

      R      : R_Node_Access;      --  R
      Q      : Q_Node_Access;      --  Q

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
         function New_Node return Node_Access;
         --  Create new node and set children nodes to it

         Item   : constant R_Node_Access := R;
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

         function New_Node return Node_Access is
            Result : constant Node_Access := New_Node (F, Prod.Index);
            Index  : Positive := 1;
         begin
            if Item.M = 0 then
               return Result;
            end if;

            for J in reverse 1 .. Item.M - 1 loop
               Set_Child (F, Result, Index, Stacks.Data (Path (J)));
               Index := Index + 1;
            end loop;

            Set_Child (F, Result, Index, Item.Node);

            return Result;
         end New_Node;

         U      : Stacks.Node;

      begin
         R := R.Next;

         while Find (U) loop
            declare
               Node : constant Node_Access := New_Node;
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
                                 Append_R (U, Node, Z, Positive (P), R);
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
                        Append_Q (W, H, Q);
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
                           Append_R (W, Null_Node, Z, 0, R);
                        elsif Item.M /= 0 then
                           Append_R (U, Node, Z, Positive (P), R);
                        end if;

                        LR_Tables.Next (T, Z);
                     end loop;
                  end;
               end if;
            end;
         end loop;

         Item.Next := Free_R;
         Free_R := Item;
      end Reducer;

      -------------
      -- Shifter --
      -------------

      procedure Shifter is
         Item : Q_Node_Access := Q;
         Un : Stacks.Node_Set := Stack.New_Node_Set;
         Qn : Q_Node_Access;  --  Q'
         Node_N : constant Node_Access := New_Token (F);  --  Ai
         Count  : Positive := 1;  --  Reuse count for Node_N
      begin
         while Item /= null loop
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
                     Reference (F, Node_N);
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
                           Append_R (V, Node_N, Z, Positive (P), R);
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
                     Reference (F, Node_N);
                  end if;

                  declare
                     H : constant LR.State_Count := LR_Tables.Shift (T, K, An);
                  begin
                     if H /= 0 then
                        Append_Q (W, H, Qn);
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
                           Append_R (W, Null_Node, Z, 0, R);
                        else
                           Append_R (V, Node_N, Z, Positive (P), R);
                        end if;

                        LR_Tables.Next (T, Z);
                     end loop;
                  end;
               end if;
            end;

            Count := Count + 1;

            declare
               Save : constant Q_Node_Access := Item;
            begin
               Item := Item.Next;
               Save.Next := Free_Q;
               Free_Q := Save;
            end;
         end loop;

         Q := Qn;
         Stack.Release (F, Ui);
         Ui := Un;
      end Shifter;

   begin
      declare
         K : constant LR.State_Count := LR_Tables.Shift (T, Initial_State, A1);
      begin
         if K /= 0 then
            Append_Q (V0, K, Q);
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
               Append_R (V0, Null_Node, R1, 0, R);
            end if;

            LR_Tables.Next (T, R1);
         end loop;
      end;

      An := A1;

      loop
         Ai := An;

         if Stacks.Is_Null (Ui) then
            Tree := Null_Node;
            return;
         end if;

         while R /= null loop
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
               Reference (F, Tree);
               exit;
            end if;

            Stacks.Next_In_Set (U);
         end loop;

         Stack.Release (F, Ui);
         Stack.Release;
      end;

   end Parse;

end Anagram.Grammars.RNGLR;
