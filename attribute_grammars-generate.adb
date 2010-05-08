with Graphs;

with Ada.Text_IO; use Ada.Text_IO;

with Attribute_Grammars.Internal;

procedure Attribute_Grammars.Generate (AG : Attribute_Grammar) is

   NT : constant Nonterminal_List := Nonterminals (AG);

   Dependency : Internal.Graph_List (NT'Range);
   Has_Cycle  : Boolean;

   function Find_Arguments
     (N : Nonterminal; Attr : Attribute_Declaration)
     return Attribute_Declaration_List
   is
      G      : Graphs.Graph renames Dependency (Index (N));
      A      : constant Graphs.Node_Index := Graphs.Node_Index (Index (Attr));
      Attrs  : Attribute_Declaration_List := Attributes (N);
      Last   : Natural := 0;
   begin
      for J in Attrs'Range loop
         if Graphs.Edge (G, Graphs.Node_Index (J), A) then
            Last := Last + 1;
            Attrs (Last) := Attrs (J);
         end if;
      end loop;

      return Attrs (1 .. Last);
   end Find_Arguments;

   procedure Gen1 (P : Production; Attr : Attribute_Declaration) is
      use Graphs;

      RL    : constant Rule_List := Rules (P);
      PL    : constant Part_List := Parts (P);

      Order : Rule_List (RL'Range);
      Last  : Natural := 0;

      function Find (P : Part; Attr : Attribute_Declaration) return Rule is
         A : Attribute;
      begin
         for R in RL'Range loop
            A := Result (RL (R));

            if not Left_Hand_Side (A) and then
              Declaration (A) = Attr and then
              Origin (A) = P
            then
               return RL (R);
            end if;
         end loop;

         raise Constraint_Error;
      end Find;

      function Find (Attr : Attribute_Declaration) return Rule is
         A : Attribute;
      begin
         for R in RL'Range loop
            A := Result (RL (R));
            if Left_Hand_Side (A) and then Declaration (A) = Attr then
               return RL (R);
            end if;
         end loop;

         raise Constraint_Error;
      end Find;

      procedure Build_Order
        (R : in     Rule)
      is
      begin
         --  skip if in list already
         for J in 1 .. Last loop
            if Order (J) = R then
               return;
            end if;
         end loop;

         Last := Last + 1;
         Order (Last) := R;

         declare
            Attrs : constant Attribute_List := Parameters (R);
            A     : Attribute_Declaration;
         begin
            for J in Attrs'Range loop
               A := Declaration (Attrs (J));

               if Left_Hand_Side (Attrs (J)) then
                  if Is_Synthesized (A) then
                     Build_Order (Find (A));
                  end if;
               else
                  Build_Order (Find (Origin (Attrs (J)), A));
               end if;
            end loop;
         end;
      end Build_Order;

   begin
      Build_Order (Find (Attr));
   end Gen1;

   procedure Generate_Function
     (N : Nonterminal; Attr : Attribute_Declaration)
   is
      Use_If   : Boolean := True;
      Prod     : constant Production_List := Productions (N);
      Arg_List : Attribute_Declaration_List := Find_Arguments (N, Attr);
   begin
      Put_Line ("function " & Name (N) & "_" & Name (Attr));
      Put_Line ("           (Node : " & Type_Name (N));

      for J in Arg_List'Range loop
         Put_Line
           (";" & Name (Arg_List (J)) & " : T_" & Name (Arg_List (J)));
      end loop;

      Put_Line (") return " & Type_Name (Attr) & " is");
      Put_Line ("begin");

      if Prod'Length > 1 and Case_Expression (N) /= "" then
         Use_If := False;
         Put_Line ("   case " & Case_Expression (N) & " is");
      end if;

      for J in Prod'Range loop
         if Prod'Length <= 1 then
            null;
         elsif Use_If then
            if J = 1 then
               Put_Line ("   if "& Kind (Prod (J)) & " then");
            elsif Kind (Prod (J)) /= "" then
               Put_Line ("   elsif "& Kind (Prod (J)) & " then");
            else
               Put_Line ("   else");
            end if;
         else
            Put_Line ("      when " & Kind (Prod (J)) & " =>");
         end if;

         Gen1 (Prod (J), Attr);
         Put_Line ("         return " & Name (Attr) & ";");
      end loop;

      if Prod'Length <= 1 then
         null;
      elsif Use_If then
         Put_Line ("   end if;");
      else
         Put_Line ("   end case;");
      end if;

      Put_Line ("end;");
   end Generate_Function;


begin
   Internal.Find_Cycle (AG, Has_Cycle, Dependency);

   if Has_Cycle then
      Put_Line ("AG has cycle");
      return;
   end if;

   for N in NT'Range loop
      declare
         Attr : constant Attribute_Declaration_List := Attributes (NT (N));
      begin
         for A in Attr'Range loop
            if Is_Synthesized (Attr (A)) then
               Generate_Function (NT (N), Attr (A));
            end if;
         end loop;
      end;
   end loop;
end Attribute_Grammars.Generate;
