------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Anagram.Graphs;

package body Anagram.Grammars.Ordered is

   type NT_Graph_Array is
     array (Non_Terminal_Index range <>) of Anagram.Graphs.Graph;

   type Graph_Array is array (Production_Index range <>)
     of Anagram.Graphs.Graph;

   ---------
   -- "<" --
   ---------

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
      use Anagram.Graphs;

      procedure Add_Production (P : Production; G : in out Graph);
      --  Initialize graph G with attribute dependencies of P
      procedure DP_To_DS (P : Production; G : Graph);
      --  Copy dependencies from production P to each symbol referenced there
      procedure DS_To_DP (P : Production; G : in out Graph);
      --  Copy dependencies to production P from each symbol referenced there
      procedure Assign_Partition (NT : Non_Terminal);
      --  Assign Partitions for each attribute of NT and fix dependency graph
      procedure Assign_Local (P : Production);
      --  Assign Partitions for each local attribute of P
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
      Local : array (Input.Production'Range) of Attribute_Declaration_Count;
      --  The same for local (per production) attribute index

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
            Local (P.Index) := Count;
            Count := Count + P.Last_Attribute - P.First_Attribute + 1;

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

      ------------------
      -- Assign_Local --
      ------------------

      procedure Assign_Local (P : Production) is
         Part       : Partition_Array renames
           Partitions (P.First_Attribute .. P.Last_Attribute);
         Unassigned : Natural := Part'Length;
         Decl       : Attribute_Declaration_Index;
         Arg        : Attribute_Declaration_Index;
         Min_Part   : Partition_Count;
      begin
         while Unassigned > 0 loop
            for Rule of Input.Rule (P.First_Rule .. P.Last_Rule) loop
               Decl := Input.Attribute (Rule.Result).Declaration;

               if Decl in Part'Range and then Part (Decl) = 0 then
                  Min_Part := 0;

                  for A in Rule.First_Argument .. Rule.Last_Argument loop
                     Arg := Input.Attribute (A).Declaration;

                     if Partitions (Arg) = 0 then
                        Min_Part := 0;
                        exit;
                     elsif Min_Part = 0 or Min_Part > Partitions (Arg) then
                        Min_Part := Partitions (Arg);
                     end if;
                  end loop;

                  if Min_Part > 0 then
                     Part (Decl) := Min_Part;
                     Unassigned := Unassigned - 1;
                  end if;
               end if;
            end loop;
         end loop;
      end Assign_Local;

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

      procedure DP_To_DS (P : Production; G : Graph) is
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
         --  Skip local attributes
         Offset := Offset
           + Node_Count (P.Last_Attribute - P.First_Attribute + 1);

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
         --  Skip local attributes
         Offset := Offset
           + Node_Count (P.Last_Attribute - P.First_Attribute + 1);

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

         function Has_Depend (J : Node_Index) return Boolean;
         --  there is AO depend on J
         function Has_Depend_On_Partition (J : Node_Index) return Boolean;
         --  there is AO depend on any AO of part+partition of J
         procedure Mark_All_Synt (J : Node_Index);
         --  mark all synt AO of part+partition of J as processed

         Mark   : array (1 .. G.Size) of Boolean := (others => False);
         --  if AO is processed
         Map    : array (1 .. G.Size) of Rule_Count := (others => 0);
         --  Map from AO to corresponding rule
         Part   : array (1 .. G.Size) of Part_Count;
         --  Map from AO to corresponding part or 0 in LHS
         Attr   : array (1 .. G.Size) of Attribute_Declaration_Index;
         --  Map from AO to corresponding attr declaration

         ----------------
         -- Has_Depend --
         ----------------

         function Has_Depend (J : Node_Index) return Boolean is
         begin
            for K in 1 .. G.Size loop
               if Edge (G, J, K) and not Mark (K) then
                  return True;
               end if;
            end loop;

            return False;
         end Has_Depend;

         -----------------------------
         -- Has_Depend_On_Partition --
         -----------------------------

         function Has_Depend_On_Partition (J : Node_Index) return Boolean is
         begin
            --  search over all attribute occurences (AO)
            for K in 1 .. G.Size loop
               --  the same part and the same partition
               if Part (J) = Part (K) and then
                 Partitions (Attr (J)) = Partitions (Attr (K)) and then
                 Has_Depend (K)
               then
                  return True;
               end if;
            end loop;

            return False;
         end Has_Depend_On_Partition;

         --------------
         -- Mark_All --
         --------------

         procedure Mark_All_Synt (J : Node_Index) is
         begin
            --  search over all attribute occurences (AO)
            for K in 1 .. G.Size loop
               --  not marked and no rule (synt attr of part)
               --  the same part and the same partition
               if not Mark (K) and Map (K) = 0 and
                 Part (J) = Part (K) and
                 Partitions (Attr (J)) = Partitions (Attr (K))
               then
                  Mark (K) := True;
               end if;
            end loop;
         end Mark_All_Synt;

         Pass     : Positive := 1;
         Max_Pass : Positive;
         Again    : Boolean := True;
         Last     : Natural := Natural (G.Size) + 1;
      begin
         --  Fill Map attr occurence to rule index
         for R of Input.Rule (P.First_Rule .. P.Last_Rule) loop
            Map (To_Index (R.Result, P)) := R.Index;
         end loop;

         --  Fill Attr and Part arrays
         declare
            Index : Node_Index := 1;
         begin
            for D in N.First_Attribute .. N.Last_Attribute loop
               Part (Index) := 0;
               Attr (Index) := D;
               Index := Index + 1;
            end loop;
            for D in P.First_Attribute .. P.Last_Attribute loop
               Part (Index) := 0;
               Attr (Index) := D;
               Index := Index + 1;
            end loop;
            for Pr of Input.Part (P.First .. P.Last) loop
               if Pr.Is_Non_Terminal_Reference then
                  declare
                     NT : Non_Terminal renames Input.Non_Terminal (Pr.Denote);
                  begin
                     for D in NT.First_Attribute .. NT.Last_Attribute loop
                        Part (Index) := Pr.Index;
                        Attr (Index) := D;
                        Index := Index + 1;
                     end loop;
                  end;
               end if;
            end loop;
         end;

         --  Calculate total pass count
         for D in N.First_Attribute .. N.Last_Attribute loop
            Pass := Positive'Max (Pass, Positive (Partitions (D) + 1) / 2);
         end loop;
         Max_Pass := Pass;

         while Again loop
            Again := False;

            --  search over all attribute occurences (AO)
            for J in 1 .. G.Size loop
               --  if AO has't processed yet and there is no (unprocessed) AO
               --  depended on it
               if not Mark (J) and then not Has_Depend (J) then
                  --  if we have rule for AO:
                  --  (synt attr of NT or inherited attr of part)
                  if Map (J) /= 0 then
                     --  if synt attr of NT then correct pass
                     if Part (J) = 0 then
                        --  Pass counted in reverse direction of partition
                        Pass := Max_Pass + 1 -
                          Positive (Partitions (Attr (J)) + 1) / 2;
                     end if;

                     Total_Order.Insert
                       ((P.Index, Pass, Last),
                        (Evaluate_Rule, Map (J)));
                  elsif Part (J) /= 0 and not Has_Depend_On_Partition (J) then
                     --  synt attr of Part (J)
                     --  and no dependency on others synt AO-s of partition
                     Total_Order.Insert
                       ((P.Index, Pass, Last),
                        (Descent, Part (J), To_Pass (Part (J), Attr (J))));
                     Mark_All_Synt (J);
                  end if;

                  Mark (J) := True;
                  Last := Last - 1;
                  Again := True;
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
         Decl   : constant Attribute_Declaration_Index :=
           Input.Attribute (X).Declaration;
      begin
         if Input.Declaration (Decl).Is_Local then
            Result := Local (P.Index) + Decl - P.First_Attribute + 1;
         elsif Input.Attribute (X).Is_Left_Hand_Side then
            Result := Decl -
              Input.Non_Terminal (P.Parent).First_Attribute + 1;
         else
            declare
               Part : Anagram.Grammars.Part renames Input.Part (Origin);
            begin
               if Part.Is_Non_Terminal_Reference then
                  NT := Part.Denote;
                  Result := Decl -
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

      for P of Input.Production loop
         Assign_Local (P);
      end loop;

      for P of Input.Production loop
         DS_To_DP (P, Induced_DP (P.Index));
      end loop;

      for N of Input.Non_Terminal loop
         for P of Input.Production (N.First .. N.Last) loop
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

end Anagram.Grammars.Ordered;
