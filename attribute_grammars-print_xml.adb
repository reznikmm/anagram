with Ada.Text_IO; use Ada.Text_IO;

procedure Attribute_Grammars.Print_XML (X : Attribute_Grammar) is
   procedure Put (X : Attribute; P : Production) is
   begin
      if Left_Hand_Side (X) then
         Put (Name (Parent (P)));
      else
         Put (Name (Origin (X)));
      end if;

      Put ("." & Name (Declaration (X)));
   end Put;

   function If_Not_Empty (Prefix, Value : String) return String is
   begin
      if Value /= "" then
         return Prefix & Value;
      else
         return "";
      end if;
   end If_Not_Empty;

   SI   : constant array (Boolean) of Character := ('S', 'I');
   List : constant Nonterminal_List := Nonterminals (X);
begin
   Put_Line ("<?xml version='1.0'?>");
   Put_Line ("<attribute_grammar>");

   for J in List'Range loop
      Put_Line ("<nonterminal name='" & Name (List (J))
                  & "' type='" & Type_Name (List (J))
                  & If_Not_Empty ("' case='", Case_Expression (List (J)))
                  & "'>");

      declare
         PL : constant Production_List := Productions (List (J));
      begin
         for P in PL'Range loop
            if Kind (PL (P)) = "" then
               Put_Line ("  <production>");
            else
               Put_Line ("  <production kind=""" & Kind (PL (P)) & """>");
            end if;

            declare
               PT : constant Part_List := Parts (PL (P));
            begin
               for T in PT'Range loop
                  Put_Line ("    <part name=""" & Name (PT (T)) &
                              """ reference='" & Name (Reference (PT (T))) &
                              "'/>");
               end loop;
            end;

            Put_Line ("  </production>");
         end loop;
      end;

      Put_Line ("</nonterminal>");
   end loop;

   Put_Line ("</attribute_grammar>");
end Attribute_Grammars.Print_XML;

