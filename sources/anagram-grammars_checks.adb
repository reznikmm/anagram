--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

with Ada.Wide_Wide_Text_IO;

package body Anagram.Grammars_Checks is

   use Anagram.Grammars;

   ---------------------
   -- Is_L_Attributed --
   ---------------------

   function Is_L_Attributed
     (Self : Anagram.Grammars.Grammar)
     return Boolean
   is

      function Check
        (Part : Part_Index;
         Attr : Attribute_Index) return Boolean;

      -----------
      -- Check --
      -----------

      function Check
        (Part : Part_Index;
         Attr : Attribute_Index) return Boolean is
      begin
         if Self.Attribute (Attr).Is_Left_Hand_Side then
            return Self.Declaration
              (Self.Attribute (Attr).Declaration).Is_Inherited;
         else
            return Self.Attribute (Attr).Origin < Part;
         end if;
      end Check;

   begin
      for J in 1 .. Self.Last_Rule loop
         declare
            Result : constant Attribute_Index := Self.Rule (J).Result;
            Attr   : Attribute renames Self.Attribute (Result);
            Decl   : Attribute_Declaration renames
              Self.Declaration (Attr.Declaration);
         begin
            if Decl.Is_Inherited and not Attr.Is_Left_Hand_Side then
               for A in
                 Self.Rule (J).First_Argument .. Self.Rule (J).Last_Argument
               loop
                  if not Check (Attr.Origin, A) then
                     return False;
                  end if;
               end loop;
            end if;
         end;
      end loop;

      return True;
   end Is_L_Attributed;

   --------------------
   -- Is_Well_Formed --
   --------------------

   function Is_Well_Formed
     (Self    : Anagram.Grammars.Grammar;
      Verbose : Boolean)
     return Boolean
   is
      function Check
        (NT : Non_Terminal_Index;
         P  : Production_Index)
        return Boolean;

      function Check_NT
        (NT   : Non_Terminal_Index;
         From : Production_Index;
         To   : Production_Count)
        return Boolean;

      type Count_Array is array (Attribute_Declaration_Index range <>)
        of Natural;

      function Check_Count
        (NT    : Non_Terminal_Index;
         Item  : Non_Terminal_Index;
         Count : Count_Array;
         Prod  : Production_Index;
         Part  : Part_Count := 0;
         RHS   : Boolean := True)
        return Boolean;

      function Check_Local
        (NT    : Non_Terminal_Index;
         Prod  : Production_Index;
         Count : Count_Array)
        return Boolean;

      -----------------
      -- Check_Count --
      -----------------

      function Check_Count
        (NT    : Non_Terminal_Index;
         Item  : Non_Terminal_Index;
         Count : Count_Array;
         Prod  : Production_Index;
         Part  : Part_Count := 0;
         RHS   : Boolean := True)
        return Boolean
      is
         function Part_Name return Wide_Wide_String;

         function Part_Name return Wide_Wide_String is
         begin
            if RHS then
               return Self.Non_Terminal (NT).Name.To_Wide_Wide_String & "." &
                 Self.Production (Prod).Name.To_Wide_Wide_String &
                 " " &
                 Self.Part (Part).Name.To_Wide_Wide_String &
                 ".";
            else
               return Self.Non_Terminal (NT).Name.To_Wide_Wide_String & "." &
                 Self.Production (Prod).Name.To_Wide_Wide_String &
                 " LHS.";
            end if;
         end Part_Name;

         Result : Boolean := True;
         From   : constant Attribute_Declaration_Index :=
           Self.Non_Terminal (Item).First_Attribute;
         To     : constant Attribute_Declaration_Count :=
           Self.Non_Terminal (Item).Last_Attribute;
      begin
         for Decl in From .. To loop
            if Self.Declaration (Decl).Is_Inherited xor RHS then
               if Count (Count'First + Decl - From) /= 0 then
                  if Verbose then
                     Ada.Wide_Wide_Text_IO.Put_Line
                       ("Not Well Formed: unexpected rule for " &
                          Part_Name &
                          Self.Declaration (Decl).Name.To_Wide_Wide_String);
                  end if;

                  Result := False;
               end if;
            else
               if Count (Count'First + Decl - From) = 0 then
                  if Verbose then
                     Ada.Wide_Wide_Text_IO.Put_Line
                       ("Not Well Formed: no rule for " &
                          Part_Name &
                          Self.Declaration (Decl).Name.To_Wide_Wide_String);
                  end if;

                  Result := False;
               elsif Count (Count'First + Decl - From) > 1 then
                  if Verbose then
                     Ada.Wide_Wide_Text_IO.Put_Line
                       ("Not Well Formed: not unique rule for " &
                          Part_Name &
                          Self.Declaration (Decl).Name.To_Wide_Wide_String);
                  end if;

                  Result := False;
               end if;
            end if;
         end loop;

         return Result;
      end Check_Count;

      -----------------
      -- Check_Local --
      -----------------

      function Check_Local
        (NT    : Non_Terminal_Index;
         Prod  : Production_Index;
         Count : Count_Array) return Boolean
      is
         Result : Boolean := True;
         From   : constant Attribute_Declaration_Index :=
           Self.Production (Prod).First_Attribute;
         To     : constant Attribute_Declaration_Count :=
           Self.Production (Prod).Last_Attribute;
      begin
         for Decl in From .. To loop
            if Count (Count'First + Decl - From) = 0 then
               if Verbose then
                  Ada.Wide_Wide_Text_IO.Put_Line
                    ("Not Well Formed: no rule for local attribute " &
                       Self.Non_Terminal (NT).Name.To_Wide_Wide_String & "." &
                       Self.Production (Prod).Name.To_Wide_Wide_String & " " &
                       Self.Declaration (Decl).Name.To_Wide_Wide_String);
               end if;

               Result := False;
            elsif Count (Count'First + Decl - From) > 1 then
               if Verbose then
                  Ada.Wide_Wide_Text_IO.Put_Line
                    ("Not Well Formed: not unique rule for local attribute " &
                       Self.Non_Terminal (NT).Name.To_Wide_Wide_String & "." &
                       Self.Production (Prod).Name.To_Wide_Wide_String & " " &
                       Self.Declaration (Decl).Name.To_Wide_Wide_String);
               end if;

               Result := False;
            end if;
         end loop;

         return Result;
      end Check_Local;

      -----------
      -- Check --
      -----------

      function Check
        (NT : Non_Terminal_Index;
         P  : Production_Index)
        return Boolean
      is
         Result : Boolean := True;
         From   : constant Part_Index := Self.Production (P).First;
         To     : constant Part_Count := Self.Production (P).Last;
         First  : array (From .. To) of Attribute_Declaration_Index;
         Offset : array (From .. To) of Attribute_Declaration_Count;

         LHS    : constant Attribute_Declaration_Count :=
           Self.Non_Terminal (NT).Last_Attribute -
           Self.Non_Terminal (NT).First_Attribute + 1;

         Local  : constant Attribute_Declaration_Count :=
           Self.Production (P).Last_Attribute -
           Self.Production (P).First_Attribute + 1;

         Total  : Attribute_Declaration_Count := LHS + Local;
      begin
         --  Fill Offset and First arrays
         for J in Offset'Range loop
            Offset (J) := Total + 1;

            if Self.Part (J).Is_Non_Terminal_Reference then
               declare
                  T : constant Non_Terminal_Index := Self.Part (J).Denote;
               begin
                  First (J) := Self.Non_Terminal (T).First_Attribute;
                  Total := Total + Self.Non_Terminal (T).Last_Attribute -
                    First (J) + 1;
               end;
            else
               First (J) := 1;
            end if;
         end loop;

         declare
            Count  : Count_Array (1 .. Total) := (others => 0);
            From   : constant Rule_Index := Self.Production (P).First_Rule;
            To     : constant Rule_Count := Self.Production (P).Last_Rule;
            Index  : Attribute_Declaration_Index;
         begin
            --  Fill Count array
            for R in From .. To loop
               declare
                  Result : constant Attribute_Index := Self.Rule (R).Result;
                  Decl   : constant Attribute_Declaration_Index :=
                    Self.Attribute (Result).Declaration;
               begin
                  if Self.Declaration (Decl).Is_Local then
                     Index := LHS +
                       Decl -
                       Self.Production (P).First_Attribute + 1;
                  elsif Self.Attribute (Result).Is_Left_Hand_Side then
                     Index := Decl -
                       Self.Non_Terminal (NT).First_Attribute + 1;
                  else
                     Index := Offset (Self.Attribute (Result).Origin) +
                       Decl -
                       First (Self.Attribute (Result).Origin);
                  end if;

                  Count (Index) := Count (Index) + 1;
               end;
            end loop;

            for J in Offset'Range loop
               if Self.Part (J).Is_Non_Terminal_Reference and then
                 not Check_Count (NT,
                                  Self.Part (J).Denote,
                                  Count (Offset (J) .. Count'Last),
                                  P,
                                  J)
               then
                  Result := False;
               end if;
            end loop;

            if not Check_Count (NT, NT, Count, P, RHS => False) then
               Result := False;
            end if;

            if not Check_Local (NT, P, Count (LHS + 1 .. LHS + Local)) then
               Result := False;
            end if;
         end;

         return Result;
      end Check;

      --------------
      -- Check_NT --
      --------------

      function Check_NT
        (NT   : Non_Terminal_Index;
         From : Production_Index;
         To   : Production_Count)
        return Boolean
      is
         Result : Boolean := True;
      begin
         for P in From .. To loop
            if not Check (NT, P) then
               Result := False;
            end if;
         end loop;

         return Result;
      end Check_NT;

      Result : Boolean := True;
   begin
      for NT in 1 .. Self.Last_Non_Terminal loop
         if not Check_NT
           (NT, Self.Non_Terminal (NT).First, Self.Non_Terminal (NT).Last)
         then
            Result := False;
         end if;
      end loop;

      return Result;
   end Is_Well_Formed;

end Anagram.Grammars_Checks;
