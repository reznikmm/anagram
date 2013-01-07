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

package body Gela.Grammars.RNGLR is

   --  This implementation is after "Right Nulled GLR Parsers" article.
   --  All identifiers are kept original

   type GSS_Node;
   type GSS_Node_Access is access all GSS_Node;

   type GSS_Node is record
      State : LR.State_Index;
      Up    : GSS_Node_Access;
      Next  : GSS_Node_Access;
   end record;

   type R_Node is record
      V         : GSS_Node_Access;
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
      L : in out Lexer'Class)
   is
      use type LR.State_Index;
      procedure Reducer;
      procedure Shifter;
      function Has_Edge (From, To : GSS_Node_Access) return Boolean;
      procedure Print (Ui : GSS_Node_Access);

      R     : R_Vectors.Vector;      --  R
      Q     : Q_Vectors.Vector;      --  Q

      V0 : constant GSS_Node_Access := new GSS_Node'(1, null, null);
      A1 : constant Terminal_Count := L.Next;
      Ai : Terminal_Count;  --  a (i+1)
      An : Terminal_Count;  --  a (i+2)
      Ui : GSS_Node_Access := V0;   --  U0 = { V0 }

      --------------
      -- Has_Edge --
      --------------

      function Has_Edge (From, To : GSS_Node_Access) return Boolean is
         Next : GSS_Node_Access := From;
      begin
         loop
            if Next.Up = To then
               return True;
            end if;

            Next := Next.Next;
            exit when Next = null or else Next.State /= From.State;
         end loop;

         return False;
      end Has_Edge;

      -------------
      -- Reducer --
      -------------

      procedure Reducer is
         function Find (Node : out GSS_Node_Access) return Boolean;
         --  Find next node at level Item.M using Path as iteration state

         Item : constant R_Node := R.Last_Element;
         X    : constant Non_Terminal_Index := G.Production
           (LR_Tables.Production (Item.Reduction)).Parent;
         Path : array (0 .. Item.M) of GSS_Node_Access;
         U    : GSS_Node_Access;

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
            end if;

            for J in reverse 1 .. Path'Last loop
               if Path (J).Next /= null and then
                 Path (J).State = Path (J).Next.State
               then
                  Path (J) := Path (J).Next;

                  if Find_First (J + 1) then
                     Node := Path (Path'Last);
                     return True;
                  end if;
               end if;
            end loop;

            return False;
         end Find;
      begin
         R.Delete_Last;

         while Find (U) loop
            declare
               K : constant LR.State_Index := U.State;
               L : constant LR.State_Index := LR_Tables.Shift (T, K, X);
               W : GSS_Node_Access := Ui;
            begin
               while W /= null and then W.State /= L loop
                  W := W.Next;
               end loop;

               if W /= null then
                  if not Has_Edge (W, U) then
                     W.Next := new GSS_Node'(State => L,
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
                                 R.Append ((U, Z, Positive (P)));
                              end if;

                              LR_Tables.Next (T, Z);
                           end loop;
                        end;
                     end if;
                  end if;
               else
                  W := new GSS_Node'(State => L,
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
                           R.Append ((W, Z, 0));
                        elsif Item.M /= 0 then
                           R.Append ((U, Z, Positive (P)));
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
                  W.Next := new GSS_Node'(State => K,
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
                           R.Append ((V, Z, Positive (P)));
                        end if;

                        LR_Tables.Next (T, Z);
                     end loop;
                  end;
               else
                  W := new GSS_Node'(State => K,
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
                           R.Append ((W, Z, 0));
                        else
                           R.Append ((V, Z, Positive (P)));
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
      if LR_Tables.Shift (T, 1, A1) /= 0 then
         Q.Append ((V0, LR_Tables.Shift (T, 1, A1)));
      end if;

      declare
         R1 : LR_Tables.Reduce_Iterator := LR_Tables.Reduce (T, 1, A1);
         P : Part_Count;
      begin
         while not LR_Tables.Is_Empty (R1) loop
            P := LR_Tables.Part (R1) + 1 -
              G.Production (LR_Tables.Production (R1)).First;

            if P = 0 then
               R.Append ((V0, R1, 0));
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

   end Parse;

end Gela.Grammars.RNGLR;
