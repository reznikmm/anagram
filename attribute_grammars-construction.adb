package body Attribute_Grammars.Construction is
   use Ada.Strings.Unbounded;

   ------------
   -- Create --
   ------------

   function Create return Attribute_Grammar is
   begin
      return new Attribute_Grammar_Node;
   end Create;

   ------------
   -- Create --
   ------------

   procedure Create
     (Object     : in out Attribute_Grammar;
      Name       : in     String;
      Type_Name  : in     String;
      Expression : in     String;
      Result     :    out Nonterminal)
   is
   begin
      Result := new Nonterminal_Node;
      Object.Last_Nonterminal := Object.Last_Nonterminal + 1;
      Object.Nonterminals (Object.Last_Nonterminal) := Result;
      Result.Index := Object.Last_Nonterminal;
      Result.Type_Name := To_Unbounded_String (Type_Name);
      Result.Name := To_Unbounded_String (Name);
      Result.Expression := To_Unbounded_String (Expression);
   end Create;

   ------------
   -- Create --
   ------------

   procedure Create
     (Object  : in out Nonterminal;
      Kind    : in     String;
      Result  :    out Production)
   is
   begin
      Result := new Production_Node;
      Object.Last_Production := Object.Last_Production + 1;
      Object.Productions (Object.Last_Production) := Result;
      Result.Parent := Object;
      Result.Kind := To_Unbounded_String (Kind);
   end Create;

   ------------
   -- Create --
   ------------

   procedure Create
     (Object    : in out Nonterminal;
      Name      : in     String;
      Type_Name : in     String;
      Result    :    out Attribute_Declaration)
   is
   begin
      Result := new Attribute_Declaration_Node;
      Object.Last_Attribute := Object.Last_Attribute + 1;
      Object.Attributes (Object.Last_Attribute) := Result;
      Result.Index := Object.Last_Attribute;
      Result.Name := To_Unbounded_String (Name);
      Result.Type_Name := To_Unbounded_String (Type_Name);
   end Create;

   ------------
   -- Create --
   ------------

   procedure Create
     (Object  : in out Production;
      Name    : in     String;
      Result  :    out Part)
   is
   begin
      Result := new Part_Node;
      Object.Last_Part := Object.Last_Part + 1;
      Object.Parts (Object.Last_Part) := Result;
      Result.Index := Object.Last_Part;
      Result.Parent := Object;
      Result.Name := To_Unbounded_String (Name);
   end Create;

   ------------
   -- Create --
   ------------

   procedure Create
     (Object  : in out Production;
      Result  :    out Rule)
   is
   begin
      Result := new Rule_Node;
      Result.Parent := Object;
      Object.Last_Rule := Object.Last_Rule + 1;
      Object.Rules (Object.Last_Rule) := Result;
   end Create;

   -------------------
   -- Create_Result --
   -------------------

   procedure Create_Result
     (Object  : in out Rule;
      Result  :    out Attribute)
   is
   begin
      Result := new Attribute_Node;
      Result.Parent := Object;
      Object.Result := Result;
   end Create_Result;

   -------------------
   -- Create_Result --
   -------------------

   procedure Create_Result
     (Object  : in out Rule;
      Result  :    out Attribute;
      Origin  : in     Part)
   is
   begin
      Result := new Attribute_Node;
      Result.Parent := Object;
      Result.Origin := Origin;
      Object.Result := Result;
   end Create_Result;

   ---------------------
   -- Create_Argument --
   ---------------------

   procedure Create_Argument
     (Object  : in out Rule;
      Result  :    out Attribute)
   is
   begin
      Result := new Attribute_Node;
      Result.Parent := Object;
      Object.Last_Parameter := Object.Last_Parameter + 1;
      Object.Parameters (Object.Last_Parameter) := Result;
   end Create_Argument;

   ---------------------
   -- Create_Argument --
   ---------------------

   procedure Create_Argument
     (Object  : in out Rule;
      Result  :    out Attribute;
      Origin  : in     Part)
   is
   begin
      Result := new Attribute_Node;
      Result.Parent := Object;
      Result.Origin := Origin;
      Object.Last_Parameter := Object.Last_Parameter + 1;
      Object.Parameters (Object.Last_Parameter) := Result;
   end Create_Argument;

   -------------------
   -- Set_Reference --
   -------------------

   procedure Set_Reference
     (Object  : in out Part;
      NT      : in     Nonterminal)
   is
   begin
      Object.Reference := NT;
   end Set_Reference;

   ---------------------
   -- Set_Declaration --
   ---------------------

   procedure Set_Declaration
     (Object  : in out Attribute;
      Decl    : in     Attribute_Declaration) is
   begin
      Object.Declaration := Decl;
   end Set_Declaration;

   --------------
   -- Set_Text --
   --------------

   procedure Set_Text
     (Object  : in out Rule;
      Text    : in     String) is
   begin
      Object.Text := To_Unbounded_String (Text);
   end Set_Text;

   ----------
   -- Find --
   ----------

   function Find
     (Object    : Production;
      Part_Name : String)
      return Part
   is
   begin
      for J in 1 .. Object.Last_Part loop
         if Name (Object.Parts (J)) = Part_Name then
            return Object.Parts (J);
         end if;
      end loop;

      raise Not_Found;
   end Find;

   ----------
   -- Find --
   ----------

   function Find
     (Object  : Attribute_Grammar;
      NT_Name : String) return Nonterminal is
   begin
      for J in 1 .. Object.Last_Nonterminal loop
         if Name (Object.Nonterminals (J)) = NT_Name then
            return Object.Nonterminals (J);
         end if;
      end loop;

      raise Not_Found;
   end Find;

   ----------
   -- Find --
   ----------

   function Find
     (Object    : Nonterminal;
      Attr_Name : String) return Attribute_Declaration is
   begin
      for J in 1 .. Object.Last_Attribute loop
         if Name (Object.Attributes (J)) = Attr_Name then
            return Object.Attributes (J);
         end if;
      end loop;

      raise Not_Found;
   end Find;

end Attribute_Grammars.Construction;
