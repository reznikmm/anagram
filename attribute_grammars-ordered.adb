with Graphs;
with Graphs.Print;
with Ada.Text_IO;

package body Attribute_Grammars.Ordered is

   type Graph_List   is array (Positive range <>) of Graphs.Graph;

   procedure Generate (AG : Attribute_Grammar; DS : Graph_List) is
      procedure W (Text : String) is
      begin
         Ada.Text_IO.Put_Line (Text);
      end W;

      procedure Procedure_Declaration
        (N : Nonterminal; Name : String; Suffix : String) is
      begin
         W ("   procedure " & Name & " (Self : " & Type_Name (N)
              & ")" & Suffix);
      end Procedure_Declaration;

      function Procedure_Name (N : Nonterminal; P : Positive) return String is
         Image : constant String := Positive'Image (P);
         Result : constant String :=
           Name (N) & "_" & Image (2 .. Image'Last);
      begin
         return Result;
      end Procedure_Name;

      procedure Generate
        (PR        : Production;
         Partition : Positive;
         Prefix    : String;
         Pos       : Positive)
      is
         use Graphs;
         type Attr_Info is record
            Decl   : Attribute_Declaration;
            Origin : Part;
         end record;

         type Attr_List is array (Positive range <>) of Attr_Info;

         G      : Graph renames DS (Pos);
         Attr   : Attr_List (1 .. Attributes (PR));
         List   : array (Attr'Range) of Positive;
         Last   : Natural := 0;
         N      : constant Nonterminal := Parent (PR);
         Decl   : constant Attribute_Declaration_List := Attributes (N);
         PL     : constant Part_List := Parts (PR);

         procedure Aaa is
            Mark : array (1 .. G.Size) of Boolean := (others => False);
            Depend : array (Boolean) of Boolean;
            Again  : Boolean := True;
         begin
            for D in Decl'Range loop
               if Decl (D).Partition < Partition then
                  Mark (Node_Index (D)) := True;
               end if;
            end loop;

            while Again loop
               Again := False;

               for J in Decl'Length + 1 .. G.Size loop
                  Depend := (others => False);

                  if not Mark (J) then
                     for K in 1 .. G.Size loop
                        if Edge (G, J, K) then
                           Depend (Mark (K)) := True;
                        end if;
                     end loop;

                     if Depend = (False, True) then
                        Mark (J) := True;
                        Again := True;
                     end if;
                  end if;
               end loop;
            end loop;

            Again := True;

            for D in Decl'Range loop
               if Decl (D).Partition = Partition then
                  Mark (Node_Index (D)) := True;
                  Last := Last + 1;
                  List (Last) := D;
               end if;
            end loop;

            while Again loop
               Again := False;

               for J in Decl'Length + 1 .. G.Size loop
                  Depend := (others => False);

                  if not Mark (J) then
                     for K in 1 .. G.Size loop
                        if Edge (G, J, K) then
                           Depend (Mark (K)) := True;
                        end if;
                     end loop;

                     if Depend = (False, True) then
                        Mark (J) := True;
                        Last := Last + 1;
                        List (Last) := Positive (J);
                        Again := True;
                     end if;
                  end if;
               end loop;
            end loop;
         end Aaa;

         procedure Fill_Attr is
            AL : constant Attribute_Declaration_List :=
              Attributes (Parent (PR));
            N : Positive := 1;
         begin
            for A in AL'Range loop
               Attr (N).Decl := AL (A);
               N := N + 1;
            end loop;

            for P in PL'Range loop
               declare
                  AL : constant Attribute_Declaration_List :=
                    Attributes (Reference (PL (P)));
               begin
                  for A in AL'Range loop
                     Attr (N).Decl := AL (A);
                     Attr (N).Origin := PL (P);
                     N := N + 1;
                  end loop;
               end;
            end loop;
         end Fill_Attr;

         RL     : constant Rule_List := Rules (PR);
         Ready  : array (PL'Range) of Natural := (others => Natural'Last);
         P      : Part;
         AD     : Attribute_Declaration;
      begin
         Fill_Attr;
         Aaa;

         for L in reverse 1 .. Last loop
            AD := Attr (List (L)).Decl;
            if List (L) in Decl'Range or Is_Inherited (AD) then
               for R in RL'Range loop
                  if Index (Result (RL (R))) = List (L) then
                     W (Prefix & Text (RL (R)));
                     exit;
                  end if;
               end loop;
            elsif AD.Partition < Ready (Index (Attr (List (L)).Origin)) then
               P := Attr (List (L)).Origin;
               W (Prefix &
                    Procedure_Name (Reference (P), AD.Partition) &
                    " (" & Name (P) & ");");
               Ready (Index (P)) := AD.Partition;
            end if;
         end loop;
      end Generate;

      procedure Generate
        (N         : Nonterminal;
         Partition : Positive;
         Pos       : Positive)
      is
         PL : constant Production_List := Productions (N);
      begin
         Procedure_Declaration (N, Procedure_Name (N, Partition), " is");
         W ("   begin");

         if PL'Length = 1 then
            Generate (PL (1), Partition, "      ", Pos);
         else
            W ("      case " & Case_Expression (N) & " is");
            for J in PL'Range loop
               W ("         when " & Kind (PL (J)) & " =>");
               Generate (PL (J), Partition, "            ", Pos + J - 1);
            end loop;
            W ("      end case;");
         end if;

         W ("   end;");
      end Generate;

      NT  : constant Nonterminal_List := Nonterminals (AG);
      Pos : Positive := 1;
   begin
      W ("package AG is");
      Procedure_Declaration (NT (1), "Evaluate", ";");
      W ("end AG;");

      W ("package body AG is");
      Procedure_Declaration (NT (1), "Evaluate", " renames " &
                               Procedure_Name (NT (1), 1) & ";");
      for N in NT'Range loop
         for J in 1 .. NT (N).Partitions loop
            if J mod 2 = 1 then
               Generate (NT (N), J, Pos);
            end if;
         end loop;

         Pos := Pos + Productions (NT (N))'Length;
      end loop;

      W ("end AG;");
   end Generate;

   function Is_Ordered (AG : Attribute_Grammar) return Boolean is
      use Graphs;
      type Boolean_List is array (Positive range <>) of Boolean;

      NL : constant Nonterminal_List := Nonterminals (AG);
      Induced_DP : Graph_List (1 .. Productions (AG));
      Induced_DS : Graph_List (NL'Range);
      DS_Changed : Boolean_List (NL'Range);
      All_False  : constant Boolean_List (NL'Range) := (others => False);

      procedure Add_Production (P : Production; G : in out Graph) is
         type Natural_Array is array (Positive range <>) of Natural;

         PL     : constant Part_List := Parts (P);
         Offset : Natural_Array (PL'Range);
         RL     : constant Rule_List := Rules (P);

         procedure Count_Offset
           (Offset : out Natural_Array;
            Total  : out Natural)
         is
            Count : Natural := Attributes (Parent (P));
         begin
            for J in PL'Range loop
               Offset (J) := Count;
               Count := Count + Attributes (Reference (PL (J)));
            end loop;

            Total := Count;
         end Count_Offset;

         procedure Add_Rule (R : Rule) is
            Res  : constant Attribute := Result (R);
            AL   : constant Attribute_List := Parameters (R);
         begin
            for A in AL'Range loop
               Set_Edge
                 (G, Node_Index (Index (AL (A))), Node_Index (Index (Res)));
            end loop;
         end Add_Rule;

         Total : Natural;
      begin
         Count_Offset (Offset, Total);
         declare
            Empty : Graph (Node_Count (Total));
         begin
            G := Empty;
         end;

         for R in RL'Range loop
            Add_Rule (RL (R));
         end loop;

         Path_Closure (G);
      end Add_Production;

      procedure DP_To_DS (P : Production; G : in out Graph) is
         Offset : Node_Count := 0;

         procedure Check (NT : Nonterminal) is
            DS_Index : constant Positive := Index (NT);
         begin
            Add_Subgraph
              (Left    => Induced_DS (DS_Index),
               Right   => G,
               Changed => DS_Changed (DS_Index),
               Shift   => Offset);

            Offset := Offset + Induced_DS (DS_Index).Size;
         end Check;

         PL     : constant Part_List := Parts (P);
      begin
         Check (Parent (P));

         for J in PL'Range loop
            Check (Reference (PL (J)));
         end loop;
      end DP_To_DS;

      procedure DS_To_DP (P : Production; G : in out Graph) is
         Offset  : Node_Count := 0;
         Changed : Boolean := False;

         procedure Check (NT : Nonterminal) is
            DS_Index : constant Positive := Index (NT);
         begin
            if DS_Changed (DS_Index) then
               Add
                 (Left    => G,
                  Right   => Induced_DS (DS_Index),
                  Shift   => Offset);

               Changed := True;
            end if;

            Offset := Offset + Induced_DS (DS_Index).Size;
         end Check;

         PL     : constant Part_List := Parts (P);
      begin
         Check (Parent (P));

         for J in PL'Range loop
            Check (Reference (PL (J)));
         end loop;

         if Changed then
            Path_Closure (G);
         end if;
      end DS_To_DP;

      procedure Assign_Partition (NT : Nonterminal) is
         subtype Partition_Number is Natural;
         type Partition_List is array (Positive range <>) of Partition_Number;


         G          : Graph renames Induced_DS (Index (NT));
         AL         : constant Attribute_Declaration_List := Attributes (NT);
         Part       : Partition_List (AL'Range) := (others => 0);
         Unassigned : Natural := Part'Length;

         function Succesors_Assigned (A : Positive) return Boolean is
         begin
            for J in 1 .. G.Size loop
               if Edge (G, Node_Index (A), J) and Part (Positive (J)) = 0 then
                  return False;
               end if;
            end loop;

            return True;
         end Succesors_Assigned;

         Changed    : Boolean := False;
         Partition  : Partition_Number := 0;
      begin
         while Unassigned > 0 loop
            Partition := Partition + 1;

            for A in AL'Range loop
               if Part (A) = 0 and then
                 Succesors_Assigned (A) and then
                 ((Is_Synthesized (AL (A)) and Partition mod 2 = 1) or
                    (Is_Inherited (AL (A)) and Partition mod 2 = 0))
               then
                  Part (A) := Partition;
                  AL (A).Partition := Partition;
                  Unassigned := Unassigned - 1;
               end if;
            end loop;
         end loop;

         NT.Partitions := Partition;

         for P in 2 .. Partition loop
            for X in AL'Range loop
               if Part (X) = P then
                  for Y in AL'Range loop
                     if Part (Y) = P - 1 then
                        if not Edge (G, Node_Index (X), Node_Index (Y)) then
                           Set_Edge (G, Node_Index (X), Node_Index (Y));
                           Changed := True;
                        end if;
                     end if;
                  end loop;
               end if;
            end loop;
         end loop;

         DS_Changed (Index (NT)) := Changed;
      end Assign_Partition;

      procedure Set_Total_Order
        (N : Nonterminal;
         P : Production;
         G : Graph)
      is
         Decl   : constant Attribute_Declaration_List := Attributes (N);
         Mark   : array (1 .. G.Size) of Boolean := (others => False);
         Depend : array (Boolean) of Boolean;
         Again  : Boolean := True;
         Order  : array (1 .. Mark'Length) of Natural := (others => 0);
         Last   : Natural := 0;
         RL     : constant Rule_List := Rules (P);
      begin
         for D in Decl'Range loop
            if Decl (D).Partition = 1 then
               Mark (Node_Index (D)) := True;
               Last := Last + 1;
               Order (D) := Last;
            end if;
         end loop;

         while Again loop
            Again := False;

            for J in 1 .. G.Size loop
               Depend := (others => False);

               if not Mark (J) then
                  for K in 1 .. G.Size loop
                     if Edge (G, J, K) then
                        Depend (Mark (K)) := True;
                     end if;
                  end loop;

                  if Depend = (False, True) then
                     Mark (J) := True;
                     Last := Last + 1;
                     Order (Positive (J)) := Last;
                     Again := True;
                  end if;
               end if;
            end loop;
         end loop;

         for R in RL'Range loop
            RL (R).Total_Order := Order (Index (Result (RL (R))));
         end loop;
      end Set_Total_Order;

      Production_Index : Positive := 1;
   begin  --  Is_Ordered
      for N in NL'Range loop
         declare
            Size  : constant Natural := Attributes (NL (N));
            Empty : Graph (Node_Count (Size));
            PL    : constant Production_List := Productions (NL (N));
         begin
            Induced_DS (N) := Empty;

            for P in PL'Range loop
               Add_Production (PL (P), Induced_DP (Production_Index));
               Production_Index := Production_Index + 1;
            end loop;
         end;
      end loop;

      loop
         DS_Changed := All_False;

         Production_Index := 1;

         for N in NL'Range loop
            declare
               PL : constant Production_List := Productions (NL (N));
            begin
               for P in PL'Range loop
                  DP_To_DS (PL (P), Induced_DP (Production_Index));
                  Production_Index := Production_Index + 1;

               end loop;
            end;
         end loop;

         exit when DS_Changed = All_False;

         Production_Index := 1;

         for N in NL'Range loop
            declare
               PL : constant Production_List := Productions (NL (N));
            begin
               for P in PL'Range loop
                  DS_To_DP (PL (P), Induced_DP (Production_Index));
                  Production_Index := Production_Index + 1;
               end loop;
            end;
         end loop;
      end loop;

      for J in Induced_DS'Range loop
         if Has_Self_Cycles (Induced_DS (J)) then
            return False;
         end if;
      end loop;

      DS_Changed := All_False;

      for N in NL'Range loop
         Assign_Partition (NL (N));
      end loop;

      Production_Index := 1;

      for N in NL'Range loop
         declare
            PL : constant Production_List := Productions (NL (N));
         begin
            for P in PL'Range loop
               DS_To_DP (PL (P), Induced_DP (Production_Index));

               if Has_Self_Cycles (Induced_DP (Production_Index)) then
                  return False;
               end if;

               Set_Total_Order (NL (N), PL (P), Induced_DP (Production_Index));
               Production_Index := Production_Index + 1;
            end loop;
         end;
      end loop;

      for J in Induced_DP'Range loop
         Ada.Text_IO.Put_Line ("Induced_DP " & (J'Img));
         Print (Induced_DP (J));
      end loop;

      for J in Induced_DS'Range loop
         Ada.Text_IO.Put_Line ("Induced_DS " & Name (NL (J)) & (NL (J).Partitions'Img));
         Print (Induced_DS (J));
      end loop;

      Generate (AG, Induced_DP);

      return True;
   end Is_Ordered;

end Attribute_Grammars.Ordered;
