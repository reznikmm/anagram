with Ada.Text_IO; use Ada.Text_IO;

procedure Attribute_Grammars.Print (X : Attribute_Grammar) is
   procedure Put (X : Attribute; P : Production) is
   begin
      if Left_Hand_Side (X) then
         Put (Name (Parent (P)));
      else
         Put (Name (Origin (X)));
      end if;

      Put ("." & Name (Declaration (X)));
   end Put;

   SI   : constant array (Boolean) of Character := ('S', 'I');
   List : constant Nonterminal_List := Nonterminals (X);
begin
   for J in List'Range loop
      Put ("Attributes for " & Name (List (J)) & " : <" );
      declare
         Attr : constant Attribute_Declaration_List := Attributes (List (J));
      begin
         for K in Attr'Range loop
            Put (Name (Attr (K)) & '[' & SI (Is_Synthesized (Attr (K))) & ']');

            if K /= Attr'Last then
               Put (", ");
            end if;
         end loop;
      end;
      Put_Line (">");

      declare
         PL : constant Production_List := Productions (List (J));
      begin
         for P in PL'Range loop
            Put (Name (List (J)) & " -> ");

            declare
               PT : constant Part_List := Parts (PL (P));
            begin
               for T in PT'Range loop
                  Put (Name (Reference (PT (T))) & "[" &
                       Name (PT (T)) & "] ");
               end loop;
            end;

            New_Line;

            declare
               RL : constant Rule_List := Rules (PL (P));
            begin
               for R in RL'Range loop
                  Put (Result (RL (R)), PL (P));
                  Put (" := F (");

                  declare
                     RP : constant Attribute_List := Parameters (RL (R));
                  begin
                     for J in RP'Range loop
                        Put (RP (J), PL (P));

                        if J /= RP'Last then
                           Put (", ");
                        end if;
                     end loop;
                  end;

                  Put_Line (")");
               end loop;
            end;

            New_Line;
         end loop;
      end;

      Put_Line ("-------------------");
   end loop;
end Attribute_Grammars.Print;

