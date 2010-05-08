with Ada.Text_IO;
procedure Attribute_Grammars.Generate_ORE (AG : Attribute_Grammar) is

   procedure W (Text : String) is
   begin
      Ada.Text_IO.Put_Line (Text);
   end W;

   procedure Procedure_Declaration
     (N : Nonterminal; Name : String; Suffix : String) is
   begin
      W ("   procedure " & Name & " (Self : " & Type_Name (N) & ")" & Suffix);
   end Procedure_Declaration;

   function Procedure_Name (N : Nonterminal; P : Positive) return String is
      Image : constant String := Positive'Image (P);
      Result : constant String :=
        Name (N) & "_" & Image (2 .. Image'Last);
   begin
      return Result;
   end Procedure_Name;

   procedure Generate (PR : Production; P : Positive; Prefix : String) is
      PL     : constant Part_List := Parts (PR);
      RL     : constant Rule_List := Rules (PR);
      Res    : Attribute_Declaration;
   begin
      null;
      --  Generate Synthesized attributes
      for R in RL'Range loop
         Res := Declaration (Result (RL (R)));

         if Is_Synthesized (Res) and Res.Partition = P * 2 - 1 then
            W (Prefix & Text (RL (R)));
         end if;
      end loop;
   end Generate;

   procedure Generate (N : Nonterminal; P : Positive) is
      PL : constant Production_List := Productions (N);
   begin
      Procedure_Declaration (N, Procedure_Name (N, P), " is");
      W ("   begin");

      if PL'Length = 1 then
         Generate (PL (1), P, "      ");
      else
         W ("      case " & Case_Expression (N) & " is");
         for J in PL'Range loop
            W ("         when " & Kind (PL (J)) & " =>");
            Generate (PL (J), P, "            ");
         end loop;
         W ("      end case;");
      end if;

      W ("   end;");
   end Generate;

   NT : constant Nonterminal_List := Nonterminals (AG);
begin
   W ("package AG is");
   Procedure_Declaration (NT (1), "Evaluate", ";");
   W ("end AG;");

   W ("package body AG is");
   Procedure_Declaration (NT (1), "Evaluate", " renames " &
                            Procedure_Name (NT (1), 1) & ";");
   for N in NT'Range loop
      for J in 1 .. (NT (N).Partitions + 1) / 2 loop
         Generate (NT (N), J);
      end loop;
   end loop;

   W ("end AG;");
end Attribute_Grammars.Generate_ORE;
