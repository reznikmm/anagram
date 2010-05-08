package body Attribute_Grammars is
   use Ada.Strings.Unbounded;

   ------------------
   -- Nonterminals --
   ------------------

   function Nonterminals (X : Attribute_Grammar) return Nonterminal_List is
   begin
      return X.Nonterminals (1 .. X.Last_Nonterminal);
   end Nonterminals;

   -----------------
   -- Productions --
   -----------------

   function Productions (X : Nonterminal) return Production_List is
   begin
      return X.Productions (1 .. X.Last_Production);
   end Productions;

   -----------------
   -- Productions --
   -----------------

   function Productions (X : Attribute_Grammar) return Natural is
      Result : Natural := 0;
      NL : constant Nonterminal_List := Nonterminals (X);
   begin
      for N in NL'Range loop
         Result := Result + Productions (NL (N))'Length;
      end loop;

      return Result;
   end Productions;

   ----------------
   -- Attributes --
   ----------------

   function Attributes
     (X : Nonterminal)
      return Attribute_Declaration_List
   is
   begin
      return X.Attributes (1 .. X.Last_Attribute);
   end Attributes;

   ----------------
   -- Attributes --
   ----------------

   function Attributes (X : Nonterminal) return Natural is
   begin
      return X.Last_Attribute;
   end Attributes;

   ----------------
   -- Attributes --
   ----------------

   function Attributes (X : Production) return Natural is
      Result : Natural := Attributes (Parent (X));
      PL : constant Part_List := Parts (X);
   begin
      for P in PL'Range loop
         Result := Result + Attributes (Reference (PL (P)));
      end loop;

      return Result;
   end Attributes;

   -----------
   -- Parts --
   -----------

   function Parts (X : Production) return Part_List is
   begin
      return X.Parts (1 .. X.Last_Part);
   end Parts;

   -----------
   -- Rules --
   -----------

   function Rules (X : Production) return Rule_List is
   begin
      return X.Rules (1 .. X.Last_Rule);
   end Rules;

   ----------
   -- Name --
   ----------

   function Name (X : Nonterminal) return String is
   begin
      return To_String (X.Name);
   end Name;

   ---------------
   -- Type_Name --
   ---------------

   function Type_Name (X : Nonterminal) return String is
   begin
      return To_String (X.Type_Name);
   end Type_Name;

   ------------
   -- Parent --
   ------------

   function Parent (X : Production) return Nonterminal is
   begin
      return X.Parent;
   end Parent;

   ------------
   -- Parent --
   ------------

   function Parent (X : Rule) return Production is
   begin
      return X.Parent;
   end Parent;

   ------------
   -- Parent --
   ------------

   function Parent (X : Attribute) return Rule is
   begin
      return X.Parent;
   end Parent;

   ----------
   -- Name --
   ----------

   function Name (X : Part) return String is
   begin
      return To_String (X.Name);
   end Name;

   ------------
   -- Parent --
   ------------

   function Parent (X : Part) return Production is
   begin
      return X.Parent;
   end Parent;

   ---------------
   -- Reference --
   ---------------

   function Reference (X : Part) return Nonterminal is
   begin
      return X.Reference;
   end Reference;

   ----------
   -- Name --
   ----------

   function Name (X : Attribute_Declaration) return String is
   begin
      return To_String (X.Name);
   end Name;

   ---------------
   -- Type_Name --
   ---------------

   function Type_Name (X : Attribute_Declaration) return String is
   begin
      return To_String (X.Type_Name);
   end Type_Name;

   ------------
   -- Result --
   ------------

   function Result (X : Rule) return Attribute is
   begin
      return X.Result;
   end Result;

   ----------------
   -- Parameters --
   ----------------

   function Parameters (X : Rule) return Attribute_List is
   begin
      return X.Parameters (1 .. X.Last_Parameter);
   end Parameters;

   -----------------
   -- Declaration --
   -----------------

   function Declaration (X : Attribute) return Attribute_Declaration is
   begin
      return X.Declaration;
   end Declaration;

   ------------
   -- Origin --
   ------------

   function Origin (X : Attribute) return Part is
   begin
      if X.Origin = null then
         raise Constraint_Error;
      end if;

      return X.Origin;
   end Origin;

   --------------------
   -- Left_Hand_Side --
   --------------------

   function Left_Hand_Side (X : Attribute) return Boolean is
   begin
      return X.Origin = null;
   end Left_Hand_Side;

   -----------
   -- Index --
   -----------

   function Index (X : Nonterminal) return Positive is
   begin
      return X.Index;
   end Index;

   -----------
   -- Index --
   -----------

   function Index (X : Part) return Positive is
   begin
      return X.Index;
   end Index;

   -----------
   -- Index --
   -----------

   function Index (X : Attribute_Declaration) return Positive is
   begin
      return X.Index;
   end Index;

   -----------
   -- Index --
   -----------

   function Index (X : Attribute) return Positive is
   begin
      if Left_Hand_Side (X) then
         return Index (Declaration (X));
      end if;

      declare
         Pr : constant Production := Parent (Parent (X));
         PL : constant Part_List := Parts (Pr);
         Result : Natural := Attributes (Parent (Pr));
      begin
         for P in 1 .. Index (Origin (X)) - 1 loop
            Result := Result + Attributes (Reference (PL (P)));
         end loop;

         Result := Result + Index (Declaration (X));

         return Result;
      end;
   end Index;

   ------------------
   -- Is_Inherited --
   ------------------

   function Is_Inherited (X : Attribute_Declaration) return Boolean is
   begin
      return X.Is_Inherited;
   end Is_Inherited;

   --------------------
   -- Is_Synthesized --
   --------------------

   function Is_Synthesized (X : Attribute_Declaration) return Boolean is
   begin
      return not X.Is_Inherited;
   end Is_Synthesized;

   -- Case_Expression --
   ---------------------

   function Case_Expression (X : Nonterminal) return String is
   begin
      return To_String (X.Expression);
   end Case_Expression;

   ----------
   -- Kind --
   ----------

   function Kind (X : Production) return String is
   begin
      return To_String (X.Kind);
   end Kind;

   ----------
   -- Text --
   ----------

   function Text (X : Rule) return String is
   begin
      return To_String (X.Text);
   end Text;

end Attribute_Grammars;
