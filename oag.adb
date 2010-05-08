with Attribute_Grammars; use Attribute_Grammars;
with Attribute_Grammars.Read_XML;

procedure OAG is
   procedure Check (AG : Attribute_Grammar) is
      procedure Check_Rule (R : Rule) is
         Res : constant Attribute := Result (R);
         PL  : constant Attribute_List := Parameters (R);
      begin
         if Left_Hand_Side (Res) and Is_Synthesized (Declaration (Res)) then
            null;
         else
            for P in PL'Range loop
               if not Is_Inherited (Declaration (PL (P))) then
                  raise Constraint_Error;
               end if;
            end loop;
         end if;
      end Check_Rule;

      NL : constant Nonterminal_List := Nonterminals (AG);
   begin
      for N in NL'Range loop
         declare
            PL : constant Production_List := Productions (NL (N));
         begin
            for P in PL'Range loop
               declare
                  RL : constant Rule_List := Rules (PL (P));
               begin
                  for R in RL'Range loop
                     Check_Rule (RL (R));
                  end loop;
               end;
            end loop;
         end;
      end loop;
   end Check;


   AG : Attribute_Grammar;
begin
   Read_XML.Read ("aaa.xml", AG);
end OAG;
