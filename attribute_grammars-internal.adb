with Ada.Text_IO;
with Graphs.Print;

package body Attribute_Grammars.Internal is

   ---------------------
   -- Attribute_Count --
   ---------------------


   function Attribute_Count (P : Production) return Natural is
      Result : Natural := Parent (P).Last_Attribute;
      List   : constant Part_List := Parts (P);
   begin
      for J in List'Range loop
         Result := Result + Reference (List (J)).Last_Attribute;
      end loop;

      return Result;
   end Attribute_Count;

   ----------------
   -- Dependency --
   ----------------

   function Dependency (P : Production) return Graphs.Graph is
      use Graphs;

      List   : constant Part_List := Parts (P);
      Offset : array (List'Range) of Natural;

      function To_Index (Attr : Attribute) return Positive is
         Inc  : Natural := 0;
         Decl : constant Attribute_Declaration := Declaration (Attr);
      begin
         if Left_Hand_Side (Attr) then
            return Index (Decl);
         else
            return Index (Decl) + Offset (Index (Origin (Attr)));
         end if;
      end To_Index;

      Size   : constant Node_Index := Node_Index (Attribute_Count (P));
      G      : Graph (Size);
   begin
      if Offset'Last > 0 then
         Offset (1) := Parent (P).Last_Attribute;
      end if;

      for J in 1 .. List'Last - 1 loop
         Offset (J + 1) := Offset (J) + Reference (List (J)).Last_Attribute;
      end loop;

      declare
         RL : constant Rule_List := Rules (P);
      begin
         for J in RL'Range loop
            declare
               Attr : constant Attribute := Result (RL (J));
               To   : constant Node_Index := Node_Index (To_Index (Attr));
               List : constant Attribute_List := Parameters (RL (J));
            begin
               for P in List'Range loop
                  declare
                     From : constant Node_Index :=
                       Node_Index (To_Index (List (P)));
                  begin
                     Set_Edge (G, From, To);
                  end;
               end loop;
            end;
         end loop;
      end;

      return G;
   end Dependency;

   ----------------
   -- Find_Cycle --
   ----------------

   procedure Find_Cycle
     (AG         : Attribute_Grammar;
      Has_Cycle  : out Boolean;
      Dep_List   : out Graph_List)
   is
      use Graphs;

      NL     : constant Nonterminal_List := Nonterminals (AG);
      G      : Graph_List renames Dep_List;

      procedure Each_Part
        (P      : Part;
         DP     : in out Graph;
         Offset : Natural)
      is
         N     : constant Nonterminal := Reference (P);
      begin
         Add (DP, G (Index (N)), Node_Count (Offset));
      end Each_Part;

      Again : Boolean := True;
   begin
      for J in NL'Range loop
         declare
            Size  : constant Positive := Attributes (NL (J));
            Empty : Graph (Node_Count (Size));
         begin
            G (J) := Empty;
         end;
      end loop;

      while Again loop
         Again := False;

         for A in NL'Range loop
            declare
               PL : constant Production_List := Productions (NL (A));
            begin
               for P in PL'Range loop
                  declare
                     Part   : constant Part_List := Parts (PL (P));
                     DP     : Graph := Dependency (PL (P));
                     Offset : Natural := Parent (PL (P)).Last_Attribute;
                  begin
                     for K in Part'Range loop
                        Each_Part (Part (K), DP, Offset);
                        Offset := Offset + Reference (Part (K)).Last_Attribute;
                     end loop;

                     Path_Closure (DP);

                     if Has_Self_Cycles (DP) then
                        Has_Cycle := True;
                        return;
                     end if;

                     Again := Again or not Difference_Is_Empty (DP, G (A));

                     Add_Subgraph (G (A), DP);
                  end;
               end loop;
            end;
         end loop;
      end loop;

      for A in NL'Range loop
         Ada.Text_IO.Put_Line ("Graph for " & Name (NL (A)));
         Graphs.Print (G (A));
         Ada.Text_IO.Put_Line ("----------");
      end loop;

      Has_Cycle := False;
   end Find_Cycle;

end Attribute_Grammars.Internal;
