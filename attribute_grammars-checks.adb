package body Attribute_Grammars.Checks is

   function Is_Well_Formed (AG : Attribute_Grammar) return Boolean is

      function Check_Production
        (P  : Production;
         PL : Part_List)
        return Boolean
      is

         type Natural_Array is array (Positive range <>) of Natural;

         Offset : Natural_Array (PL'Range);
         Total  : constant Natural := Attributes (P);
         Count : Natural_Array (1 .. Total) := (others => 0);

         procedure Count_Attributes (Offset : out Natural_Array) is
            Count : Natural := Attributes (Parent (P));
         begin
            for J in PL'Range loop
               Offset (J) := Count;
               Count := Count + Attributes (Reference (PL (J)));
            end loop;
         end Count_Attributes;

         procedure Increment (Value : in out Natural) is
         begin
            Value := Value + 1;
         end Increment;

         procedure Check_Rule (R : Rule; Count : in out Natural_Array) is
            Res : constant Attribute := Result (R);
            Pos : Natural;
         begin
            if Left_Hand_Side (Res) then
               Pos := 0;
            else
               Pos := Offset (Index (Origin (Res)));
            end if;

            Pos := Pos + Index (Declaration (Res));
            Increment (Count (Pos));
         end Check_Rule;

      begin  --  Check_Production
         Count_Attributes (Offset);

         declare
            RL    : constant Rule_List := Rules (P);
            Count : Natural_Array (1 .. Total) := (others => 0);
         begin
            for R in RL'Range loop
               Check_Rule (RL (R), Count);
            end loop;

            declare
               AL : constant Attribute_Declaration_List :=
                 Attributes (Parent (P));
            begin
               for A in AL'Range loop
                  if (Is_Synthesized (AL (A)) and Count (A) /= 1) or
                    (not Is_Synthesized (AL (A)) and Count (A) /= 0)
                  then
                     return False;
                  end if;
               end loop;
            end;

            for J in PL'Range loop
               declare
                  Pos : Positive := Offset (J);
                  AL : constant Attribute_Declaration_List :=
                    Attributes (Reference (PL (J)));
               begin
                  for A in AL'Range loop
                     Pos := Pos + 1;

                     if (not Is_Synthesized (AL (A)) and Count (Pos) /= 1) or
                       (Is_Synthesized (AL (A)) and Count (Pos) /= 0)
                     then
                        return False;
                     end if;
                  end loop;
               end;
            end loop;
         end;

         return True;
      end Check_Production;

      NL : constant Nonterminal_List := Nonterminals (AG);
   begin
      for N in NL'Range loop
         declare
            PL : constant Production_List := Productions (NL (N));
         begin
            for P in PL'Range loop
               if not Check_Production (PL (P), Parts (PL (P))) then
                  return False;
               end if;
            end loop;
         end;
      end loop;

      return True;
   end Is_Well_Formed;

   function In_Normal_Form (AG : Attribute_Grammar) return Boolean is
      function Check_Rule (R : Rule) return Boolean is
         AL  : constant Attribute_List := Parameters (R);
      begin
         for A in AL'Range loop
            if Left_Hand_Side (AL (A)) and
              Is_Synthesized (Declaration (AL (A)))
            then
               return False;
            elsif not Left_Hand_Side (AL (A)) and
              not Is_Synthesized (Declaration (AL (A)))
            then
               return False;
            end if;
         end loop;

         return True;
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
                     if not Check_Rule (RL (R)) then
                        return False;
                     end if;
                  end loop;
               end;
            end loop;
         end;
      end loop;

      return True;
   end In_Normal_Form;

end Attribute_Grammars.Checks;
