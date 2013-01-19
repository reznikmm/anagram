------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Ada.Containers.Vectors;
with Ada.Wide_Wide_Text_IO;

with Gela.Grammars.LR;
with Gela.Grammars.LR_Tables;

package body Gela.Grammars.RNGLR is

   --  This implementation is after "Right Nulled GLR Parsers" article.
   --  All one letter identifiers are kept original

   type GSS_Node;
   type GSS_Node_Access is access all GSS_Node;

   type GSS_Node is record
      State : LR.State_Index;
      Node  : AST_Nodes.Node_Access;
      Count : Positive;
      Up    : GSS_Node_Access;
      Next  : GSS_Node_Access;
   end record;

   type R_Node is record
      V         : GSS_Node_Access;
      Node      : AST_Nodes.Node_Access;
      Reduction : LR_Tables.Reduce_Iterator;
      M         : Natural;
   end record;

   package R_Vectors is new Ada.Containers.Vectors (Positive, R_Node);

   type Q_Node is record
      V : GSS_Node_Access;
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
      function Get_Edge (From, To : GSS_Node_Access) return GSS_Node_Access;
      procedure Print (Ui : GSS_Node_Access);

      R     : R_Vectors.Vector;      --  R
      Q     : Q_Vectors.Vector;      --  Q

      A1 : constant Terminal_Count := L.Next;
      V0 : constant GSS_Node_Access :=
        new GSS_Node'(1, null, 1, null, null);
      Ai : Terminal_Count;  --  a (i+1)
      An : Terminal_Count;  --  a (i+2)
      Ui : GSS_Node_Access := V0;   --  U0 = { V0 }

      --------------
      -- Get_Edge --
      --------------

      function Get_Edge (From, To : GSS_Node_Access) return GSS_Node_Access is
         Next : GSS_Node_Access := From;
      begin
         loop
            if Next.Up = To then
               return Next;
            end if;

            Next := Next.Next;
            exit when Next = null or else Next.State /= From.State;
         end loop;

         return null;
      end Get_Edge;

      -------------
      -- Reducer --
      -------------

      procedure Reducer is
         function Find (Node : out GSS_Node_Access) return Boolean;
         --  Find next node at level Item.M-1 using Path as iteration state
         function New_Alternative
           (Left, Right : AST_Nodes.Node_Access) return AST_Nodes.Node_Access;
         --  Create new alternative and append Left, Right nodes to it
         function New_Node return AST_Nodes.Node_Access;

         Item   : constant R_Node := R.First_Element;
         Prod   : Production renames G.Production
           (LR_Tables.Production (Item.Reduction));
         X      : constant Non_Terminal_Index := Prod.Parent;
         Length : constant Natural := Natural'Max (0, Item.M - 1);
         Path   : array (0 .. Length) of GSS_Node_Access;
         U      : GSS_Node_Access;

         ----------
         -- Find --
         ----------

         function Find (Node : out GSS_Node_Access) return Boolean is
            function Find_First (From : Positive) return Boolean;

            ----------------
            -- Find_First --
            ----------------

            function Find_First (From : Positive) return Boolean is
            begin
               for J in From .. Path'Last loop
                  Path (J) := Path (J - 1).Up;

                  if Path (J) = null then
                     return False;
                  end if;
               end loop;

               return True;
            end Find_First;
         begin
            if Path (0) = null then
               Path (0) := Item.V;

               if Find_First (1) then
                  Node := Path (Path'Last);
                  return True;
               else
                  return False;
               end if;
            elsif Length = 0 then
               return False;
            end if;

            for J in reverse 0 .. Path'Last loop
               while Path (J).Next /= null and then
                 Path (J).State = Path (J).Next.State
               loop
                  Path (J) := Path (J).Next;

                  if Find_First (J + 1) then
                     Node := Path (Path'Last);
                     return True;
                  end if;
               end loop;
            end loop;

            return False;
         end Find;

         ---------------------
         -- New_Alternative --
         ---------------------

         function New_Alternative
           (Left, Right : AST_Nodes.Node_Access)
            return AST_Nodes.Node_Access
         is
            Result : constant AST_Nodes.Node_Access := F.New_Alternative (X);
         begin
            Result.Set_Child (1, Left);
            Result.Set_Child (2, Right);
            return Result;
         end New_Alternative;

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

            for J in reverse 0 .. Item.M - 2 loop
               Result.Set_Child (Index, Path (J).Node);
               Index := Index + 1;
            end loop;

            Result.Set_Child (Index, Item.Node);

            return Result;
         end New_Node;

      begin
         R.Delete_First;

         while Find (U) loop
            declare
               Node : AST_Nodes.Node_Access := New_Node;
               Edge : GSS_Node_Access;
               K : constant LR.State_Index := U.State;
               L : constant LR.State_Index := LR_Tables.Shift (T, K, X);
               W : GSS_Node_Access := Ui;
            begin
               while W /= null and then W.State /= L loop
                  W := W.Next;
               end loop;

               if W /= null then
                  Edge := Get_Edge (W, U);

                  if Edge = null then
                     W.Next := new GSS_Node'(State => L,
                                             Node  => Node,
                                             Count => 1,
                                             Up    => U,
                                             Next  => W.Next);

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
                     Edge.Count := Edge.Count + 1;

                     if Edge.Count = 2 then
                        --  Convert old node to alternative
                        Edge.Node := New_Alternative (Edge.Node, Node);
                     else
                        --  Just add new node to alternative
                        Edge.Node.Set_Child (Edge.Count, Node);
                     end if;
                  end if;
               else
                  W := new GSS_Node'(State => L,
                                     Node  => Node,
                                     Count => 1,
                                     Up    => U,
                                     Next  => Ui);
                  Ui := W;

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
         Un : GSS_Node_Access := null;
         Qn : Q_Vectors.Vector;  --  Q'
         Node_N : constant AST_Nodes.Node_Access := F.New_Token;  --  Ai
      begin
         for Item of Q loop
            declare
               V : constant GSS_Node_Access := Item.V;
               K : constant LR.State_Index := Item.K;
               W : GSS_Node_Access := Un;
            begin

               while W /= null and then W.State /= K loop
                  W := W.Next;
               end loop;

               if W /= null then
                  W.Count := W.Count + 1;
                  W.Next := new GSS_Node'(State => K,
                                          Node  => Node_N,
                                          Count => 1,
                                          Up    => V,
                                          Next  => W.Next);

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
                  W := new GSS_Node'(State => K,
                                     Node  => Node_N,
                                     Count => 1,
                                     Up    => V,
                                     Next  => Un);
                  Un := W;

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
         end loop;

         Q := Qn;
         Ui := Un;
      end Shifter;

      procedure Print (Ui : GSS_Node_Access) is
         w : GSS_Node_Access := Ui;
      begin
         Ada.Wide_Wide_Text_IO.Put_Line ("Next cycle");
         while w /= null loop
            Ada.Wide_Wide_Text_IO.Put_Line
              (LR.State_Index'Wide_Wide_Image (w.State));

            if w.Up /= null then
               Ada.Wide_Wide_Text_IO.Put_Line
                ("  UP:" & LR.State_Index'Wide_Wide_Image (w.Up.State));
            end if;

            w := w.Next;
         end loop;
      end Print;

   begin
      declare
         K : constant LR.State_Count := LR_Tables.Shift (T, V0.State, A1);
      begin
         if K /= 0 then
            Q.Append ((V0, K));
         end if;
      end;

      declare
         R1 : LR_Tables.Reduce_Iterator := LR_Tables.Reduce (T, V0.State, A1);
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

      Print (Ui);
      An := A1;

      loop
         Ai := An;

         if Ui = null then
            raise Constraint_Error;
         end if;

         while not R.Is_Empty loop
            Reducer;
         end loop;

         if Ai /= 0 then
            An := L.Next;
            Shifter;
         end if;
         Print (Ui);

         exit when Ai = 0;
      end loop;

      declare
         U : GSS_Node_Access := Ui;
      begin
         while U /= null loop
            if LR_Tables.Finish (T, U.State) then
               Tree := U.Node;
               exit;
            end if;

            U := U.Next;
         end loop;
      end;

   end Parse;

end Gela.Grammars.RNGLR;
