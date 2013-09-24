------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Gela.Graphs;

package body Gela.Grammars.Ordered is

   type NT_Graph_Array is
     array (Non_Terminal_Index range <>) of Gela.Graphs.Graph;

   type Graph_Array is array (Production_Index range <>) of Gela.Graphs.Graph;

   function "<" (Left, Right : Key) return Boolean is
   begin
      return Left.Prod < Right.Prod or
        (Left.Prod = Right.Prod and Left.Pass < Right.Pass) or
        (Left.Prod = Right.Prod and
         Left.Pass = Right.Pass and
         Left.Step < Right.Step);
   end "<";

   ----------------
   -- Find_Order --
   ----------------

   procedure Find_Order
     (Input      : Grammar;
      Found      : out Boolean;
      Partitions : out Partition_Array;
      Order      : out Order_Maps.Map)
   is
      use Gela.Graphs;

      procedure Add_Production (P : Production; G : in out Graph);
      --  Initialize graph G with attribute dependencies of P
      procedure DP_To_DS (P : Production; G : in out Graph);
      --  Copy dependencies from production P to each symbol referenced there
      procedure DS_To_DP (P : Production; G : in out Graph);
      --  Copy dependencies to production P from each symbol referenced there
      procedure Assign_Partition (NT : Non_Terminal);
      --  Assign Partitions for each attribute of NT and fix dependency graph
      function To_Index
        (X : Attribute_Index; P : Production) return Node_Index;
      --  Find (per production) attribute index
      procedure Set_Total_Order
        (N : Non_Terminal;
         P : Production;
         G : Graph;
         Total_Order : out Order_Maps.Map);
      function To_Pass
        (Part : Part_Count;
         Attr : Attribute_Declaration_Index) return Natural;

      Induced_DP : Graph_Array (Input.Production'Range);
      --  Dependencies between attributes of each production
      Induced_DS : NT_Graph_Array (Input.Non_Terminal'Range);
      --  Dependencies between attributes of each non-terminal

      type Boolean_List is array (Input.Non_Terminal'Range) of Boolean;
      All_False  : constant Boolean_List := (others => False);
      DS_Changed : Boolean_List;

      Offset : array (Input.Part'Range) of Attribute_Declaration_Count;
      --  Map between part index and (per production) attribute index

      --------------------
      -- Add_Production --
      --------------------

      procedure Add_Production (P : Production; G : in out Graph) is

         procedure Count_Offset (Total : out Attribute_Declaration_Count);
         procedure Add_Rule (R : Rule);

         ------------------
         -- Count_Offset --
         ------------------

         procedure Count_Offset (Total : out Attribute_Declaration_Count) is
            NT    : Non_Terminal_Index;
            Count : Attribute_Declaration_Count :=
              Input.Non_Terminal (P.Parent).Last_Attribute -
              Input.Non_Terminal (P.Parent).First_Attribute + 1;
         begin
            for Part of Input.Part (P.First .. P.Last) loop
               Offset (Part.Index) := Count;

               if Part.Is_Non_Terminal_Reference then
                  NT := Part.Denote;
                  Count := Count +
                    Input.Non_Terminal (NT).Last_Attribute -
                    Input.Non_Terminal (NT).First_Attribute + 1;
               end if;
            end loop;

            Total := Count;
         end Count_Offset;

         --------------
         -- Add_Rule --
         --------------

         procedure Add_Rule (R : Rule) is
            Res  : constant Attribute_Index := R.Result;
            To   : constant Node_Index := To_Index (Res, P);
         begin
            for A in R.First_Argument .. R.Last_Argument loop
               declare
                  Attr : Attribute renames Input.Attribute (A);
               begin
                  if Attr.Is_Left_Hand_Side or else
                    Input.Part (Attr.Origin).Is_Non_Terminal_Reference
                  then
                     Set_Edge (G, To_Index (A, P), To);
                  end if;
               end;
            end loop;
         end Add_Rule;

         Total : Attribute_Declaration_Count;
      begin
         Count_Offset (Total);

         declare  --  Shrink graph G to corresponding size
            Empty : Graph (Node_Count (Total));
         begin
            G := Empty;
         end;

         for Rule of Input.Rule (P.First_Rule .. P.Last_Rule) loop
            Add_Rule (Rule);
         end loop;

         Path_Closure (G);
      end Add_Production;

      ----------------------
      -- Assign_Partition --
      ----------------------

      procedure Assign_Partition (NT : Non_Terminal) is
         function Succesors_Assigned
           (A : Attribute_Declaration_Index) return Boolean;

         G          : Graph renames Induced_DS (NT.Index);
         Part       : Partition_Array renames
           Partitions (NT.First_Attribute .. NT.Last_Attribute);
         Unassigned : Natural := Part'Length;

         function To_Node
           (Attr : Attribute_Declaration_Index) return Node_Index;

         -------------
         -- To_Node --
         -------------

         function To_Node
           (Attr : Attribute_Declaration_Index) return Node_Index is
         begin
            return Node_Index (Attr - Part'First + 1);
         end To_Node;

         ------------------------
         -- Succesors_Assigned --
         ------------------------

         function Succesors_Assigned
           (A : Attribute_Declaration_Index) return Boolean
         is
            Index : constant Node_Index := To_Node (A);
         begin
            for J in 1 .. G.Size loop
               if Edge (G, Index, J) and
                 Part (Attribute_Declaration_Index (J) + Part'First - 1) = 0
               then
                  return False;
               end if;
            end loop;

            return True;
         end Succesors_Assigned;

         Partition  : Partition_Count := 0;
      begin
         while Unassigned > 0 loop
            Partition := Partition + 1;

            for A of Input.Declaration (Part'Range) loop
               if Part (A.Index) = 0 and then
                 Succesors_Assigned (A.Index) and then
                 ((not A.Is_Inherited and Partition mod 2 = 1) or
                    (A.Is_Inherited and Partition mod 2 = 0))
               then
                  Part (A.Index) := Partition;
                  Unassigned := Unassigned - 1;
               end if;
            end loop;
         end loop;

         for P in 2 .. Partition loop
            for X in Part'Range loop
               if Part (X) = P then
                  for Y in Part'Range loop
                     if Part (Y) = P - 1 then
                        if not Edge (G, To_Node (X), To_Node (Y)) then
                           Set_Edge (G, To_Node (X), To_Node (Y));
                           DS_Changed (NT.Index) := True;
                        end if;
                     end if;
                  end loop;
               end if;
            end loop;
         end loop;
      end Assign_Partition;

      --------------
      -- DP_To_DS --
      --------------

      procedure DP_To_DS (P : Production; G : in out Graph) is
         procedure Each_NT (NT : Non_Terminal_Index);
         Offset : Node_Count := 0;

         procedure Each_NT (NT : Non_Terminal_Index) is
         begin
            Add_Subgraph
              (Left    => Induced_DS (NT),
               Right   => G,
               Changed => DS_Changed (NT),
               Shift   => Offset);

            Offset := Offset + Induced_DS (NT).Size;
         end Each_NT;

      begin
         Each_NT (P.Parent);

         for Part of Input.Part (P.First .. P.Last) loop
            if Part.Is_Non_Terminal_Reference then
               Each_NT (Part.Denote);
            end if;
         end loop;
      end DP_To_DS;

      --------------
      -- DS_To_DP --
      --------------

      procedure DS_To_DP (P : Production; G : in out Graph) is
         procedure Each_NT (NT : Non_Terminal_Index);

         Offset  : Node_Count := 0;
         Changed : Boolean := False;

         procedure Each_NT (NT : Non_Terminal_Index) is
         begin
            if DS_Changed (NT) then
               Add
                 (Left    => G,
                  Right   => Induced_DS (NT),
                  Shift   => Offset);

               Changed := True;
            end if;

            Offset := Offset + Induced_DS (NT).Size;
         end Each_NT;

      begin
         Each_NT (P.Parent);

         for Part of Input.Part (P.First .. P.Last) loop
            if Part.Is_Non_Terminal_Reference then
               Each_NT (Part.Denote);
            end if;
         end loop;

         if Changed then
            Path_Closure (G);
         end if;
      end DS_To_DP;

      ---------------------
      -- Set_Total_Order --
      ---------------------

      procedure Set_Total_Order
        (N : Non_Terminal;
         P : Production;
         G : Graph;
         Total_Order : out Order_Maps.Map)
      is

         procedure To_Part
           (J    : Node_Index;
            Part : out Part_Count;
            Attr : out Attribute_Declaration_Index);

         -------------
         -- To_Part --
         -------------

         procedure To_Part
           (J    : Node_Index;
            Part : out Part_Count;
            Attr : out Attribute_Declaration_Index)
         is
            Count : constant Attribute_Declaration_Index :=
              Attribute_Declaration_Index (J);
         begin
            Part := 0;
            Attr := 1;
            for K in P.First .. P.Last loop
               if Count <= Offset (K) then
                  return;
               elsif Input.Part (K).Is_Non_Terminal_Reference then
                  declare
                     NT : Non_Terminal renames
                       Input.Non_Terminal (Input.Part (K).Denote);
                  begin
                     Part := K;
                     Attr := NT.First_Attribute + Count - Offset (K) - 1;
                  end;
               end if;
            end loop;
         end To_Part;

         Pass   : Positive := 1;
         Part   : Partition_Index := 1;
         Mark   : array (1 .. G.Size) of Boolean := (others => False);
         Map    : array (1 .. G.Size) of Rule_Count := (others => 0);
         Depend : Boolean;
         Again  : Boolean := True;
         Last   : Natural := Natural (G.Size) + 1;
      begin
         for R of Input.Rule (P.First_Rule .. P.Last_Rule) loop
            Map (To_Index (R.Result, P)) := R.Index;
         end loop;

         --  Calculate total pass count and corresponding partition
         for D in N.First_Attribute .. N.Last_Attribute loop
            if Partitions (D) mod 2 = 1 then
               declare
                  New_Pass : constant Positive := To_Pass
                    (Partitions (N.First_Attribute .. N.Last_Attribute), D);
               begin
                  if New_Pass >= Pass then
                     Pass := New_Pass;
                     Part := Partitions (D);
                  end if;
               end;
            end if;
         end loop;

         for D in N.First_Attribute .. N.Last_Attribute loop
            if Partitions (D) = Part then
               declare
                  Index : constant Node_Index :=
                    Node_Index (D - N.First_Attribute + 1);
               begin
                  Mark (Index) := True;
                  Total_Order.Insert
                    ((P.Index, Pass, Last), (Evaluate_Rule, Map (Index)));
                  Last := Last - 1;
               end;
            end if;
         end loop;

         while Again loop
            Again := False;

            for J in 1 .. G.Size loop
               if not Mark (J) then
                  Depend := True;

                  for K in 1 .. G.Size loop
                     if Edge (G, J, K) and not Mark (K) then
                        Depend := False;
                        exit;
                     end if;
                  end loop;

                  if Depend then
                     if Map (J) = 0 then
                        declare
                           Part : Part_Count;
                           Attr : Attribute_Declaration_Index;
                        begin
                           To_Part (J, Part, Attr);

                           if Part /= 0  then
                              Total_Order.Insert
                                ((P.Index, Pass, Last),
                                 (Descent, Part, To_Pass (Part, Attr)));
                           end if;
                        end;
                     else
                        declare
                           R : Rule renames Input.Rule (Map (J));
                           A : Attribute renames Input.Attribute (R.Result);
                        begin
                           if A.Is_Left_Hand_Side and
                             Partitions (A.Declaration) /= Part
                           then
                              Pass := Pass - 1;
                              Part := Partitions (A.Declaration);
                           end if;

                           Total_Order.Insert
                             ((P.Index, Pass, Last),
                              (Evaluate_Rule, R.Index));
                        end;
                     end if;

                     Mark (J) := True;
                     Last := Last - 1;
                     Again := True;
                  end if;
               end if;
            end loop;
         end loop;

      end Set_Total_Order;

      --------------
      -- To_Index --
      --------------

      function To_Index
        (X : Attribute_Index; P : Production) return Node_Index
      is
         NT     : Non_Terminal_Index;
         Result : Attribute_Declaration_Count;
         Origin : constant Part_Count := Input.Attribute (X).Origin;
      begin
         if Input.Attribute (X).Is_Left_Hand_Side then
            Result := Input.Attribute (X).Declaration -
              Input.Non_Terminal (P.Parent).First_Attribute + 1;
         else
            declare
               Part : Gela.Grammars.Part renames Input.Part (Origin);
            begin
               if Part.Is_Non_Terminal_Reference then
                  NT := Part.Denote;
                  Result := Input.Attribute (X).Declaration -
                    Input.Non_Terminal (NT).First_Attribute + 1;
               end if;

               Result := Result + Offset (Origin);
            end;
         end if;

         return Node_Index (Result);
      end To_Index;

      -------------
      -- To_Pass --
      -------------

      function To_Pass
        (Part : Part_Count;
         Attr : Attribute_Declaration_Index) return Natural
      is
         P  : Grammars.Part renames Input.Part (Part);
         NT : Non_Terminal renames Input.Non_Terminal (P.Denote);
      begin
         return To_Pass
           (Partitions (NT.First_Attribute .. NT.Last_Attribute), Attr);
      end To_Pass;
   begin
      --  Initialize Induced_DP and clear Induced_DS
      for N of Input.Non_Terminal loop
         declare
            Size  : constant Attribute_Declaration_Count :=
              N.Last_Attribute - N.First_Attribute + 1;
            Empty : Graph (Node_Count (Size));
         begin
            Induced_DS (N.Index) := Empty;  --  Shrink DS graph to Size

            for P of Input.Production (N.First .. N.Last) loop
               Add_Production (P, Induced_DP (P.Index));
            end loop;
         end;
      end loop;

      loop
         DS_Changed := All_False;

         for P of Input.Production loop
            DP_To_DS (P, Induced_DP (P.Index));
         end loop;

         exit when DS_Changed = All_False;

         for P of Input.Production loop
            DS_To_DP (P, Induced_DP (P.Index));
         end loop;
      end loop;

      for J in Induced_DS'Range loop
         if Has_Self_Cycles (Induced_DS (J)) then
            Found := False;
            return;
         end if;
      end loop;

      Partitions := (others => 0);

      for NT of Input.Non_Terminal loop
         Assign_Partition (NT);
      end loop;

      for N of Input.Non_Terminal loop
         for P of Input.Production (N.First .. N.Last) loop
            DS_To_DP (P, Induced_DP (P.Index));

            if Has_Self_Cycles (Induced_DP (P.Index)) then
               Found := False;
               return;
            end if;

            Set_Total_Order (N, P, Induced_DP (P.Index), Order);
         end loop;
      end loop;

      Found := True;
   end Find_Order;

   -------------
   -- To_Pass --
   -------------

   function To_Pass
     (Partitions : Partition_Array;
      Attr       : Attribute_Declaration_Index) return Natural
   is
      Pass   : constant Partition_Index := (Partitions (Attr) + 1) / 2;
      Max    : Partition_Count := 0;
   begin
      for J of Partitions loop
         Max := Partition_Count'Max (Max, J);
      end loop;

      return Natural ((Max + 1) / 2 - Pass + 1);
   end To_Pass;

end Gela.Grammars.Ordered;
