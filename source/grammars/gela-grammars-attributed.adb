------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

package body Gela.Grammars.Attributed is

   package body Nodes is
      use type S.Universal_String;

      ---------
      -- "<" --
      ---------

      function "<" (Left, Right : Declaration_Key) return Boolean is
      begin
         return Left.Parent < Right.Parent or else
           (Left.Parent = Right.Parent and Left.Name < Right.Name);
      end "<";

      ---------
      -- "<" --
      ---------

      function "<" (Left, Right : Rule_Key) return Boolean is
      begin
         return Left.Parent < Right.Parent or else
           (Left.Parent = Right.Parent and Left.Rule_Index < Right.Rule_Index);
      end "<";

      ---------
      -- "<" --
      ---------

      function "<" (Left, Right : Attribute_Key) return Boolean is
      begin
         return Left.Parent < Right.Parent or else
           (Left.Parent = Right.Parent and Left.Attr_Index < Right.Attr_Index);
      end "<";

   end Nodes;

   ------------------
   -- Is_Inherited --
   ------------------

   function Is_Inherited
     (Self : access Attribute_Declaration)
      return Boolean
   is
   begin
      return Self.Is_Inherited;
   end Is_Inherited;

   ----------
   -- Name --
   ----------

   function Name
     (Self : access Attribute_Declaration)
      return S.Universal_String
   is
   begin
      return Self.Name;
   end Name;

   -----------
   -- Index --
   -----------

   function Index
     (Self : access Attribute_Declaration)
      return Attribute_Declaration_Index
   is
   begin
      return Self.Index;
   end Index;

   -----------------------
   -- Is_Left_Hand_Side --
   -----------------------

   function Is_Left_Hand_Side (Self : access Attribute) return Boolean is
   begin
      return Self.Origin = 0;
   end Is_Left_Hand_Side;

   -----------
   -- Index --
   -----------

   function Index
     (Self : access Attribute)
      return Attribute_Index
   is
   begin
      return Self.Index;
   end Index;

   ------------
   -- Origin --
   ------------

   function Origin (Self : access Attribute) return Part_Count is
   begin
      return Self.Origin;
   end Origin;

   -----------------
   -- Declaration --
   -----------------

   function Declaration
     (Self : access Attribute)
      return Attribute_Declaration_Index
   is
   begin
      return Self.Declaration;
   end Declaration;

   -----------
   -- Index --
   -----------

   function Index (Self : access Rule) return Rule_Index is
   begin
      return Self.Index;
   end Index;

   ------------
   -- Result --
   ------------

   function Result (Self : access Rule) return Attribute_Index is
   begin
      return Self.Result;
   end Result;

   --------------------
   -- Argument_First --
   --------------------

   function Argument_First (Self : access Rule) return Attribute_Index is
   begin
      return Self.Argument_First;
   end Argument_First;

   -------------------
   -- Argument_Last --
   -------------------

   function Argument_Last (Self : access Rule) return Attribute_Count is
   begin
      return Self.Argument_Last;
   end Argument_Last;

   ------------
   -- Parent --
   ------------

   function Parent (Self : access Rule) return Production_Index is
   begin
      return Self.Parent;
   end Parent;

   -----------
   -- First --
   -----------

   function First
     (Self : access Terminal)
      return Attribute_Declaration_Index
   is
   begin
      return Self.First_Attribute;
   end First;

   ----------
   -- Last --
   ----------

   function Last
     (Self : access Terminal)
      return Attribute_Declaration_Count
   is
   begin
      return Self.Last_Attribute;
   end Last;

   -----------
   -- First --
   -----------

   function First
     (Self : access Non_Terminal)
      return Attribute_Declaration_Index
   is
   begin
      return Self.First_Attribute;
   end First;

   ----------
   -- Last --
   ----------

   function Last
     (Self : access Non_Terminal)
      return Attribute_Declaration_Count
   is
   begin
      return Self.Last_Attribute;
   end Last;

   -----------
   -- First --
   -----------

   function First (Self : access Production) return Rule_Index is
   begin
      return Self.First_Rule;
   end First;

   ----------
   -- Last --
   ----------

   function Last (Self : access Production) return Rule_Count is
   begin
      return Self.Last_Rule;
   end Last;

   procedure Copy_Attributes
     (Self   : Constructor;
      Result : out Attribute_Array)
   is
      Index : Attribute_Index := Result'First;

      use Constructor_Nodes, Nodes;

      procedure Each (Cursor : Attribute_Maps.Cursor);

      procedure Each (Cursor : Attribute_Maps.Cursor) is
         Key  : constant Attribute_Key := Attribute_Maps.Key (Cursor);
         Node : constant Attribute_Node := Attribute_Maps.Element (Cursor);
         Item : Rule renames Self.Rules.Element (Key.Parent).all;
         Decl : Declaration_Key;
      begin
         Result (Index).Index := Index;

         if Node.Origin.Part_Index = 0 then
            Result (Index).Origin := 0;
            Decl := (Key.Parent.Parent.Parent, Node.Attr_Name);
         else
            declare
               Origin : Part'Class renames
                 Self.Part_Map.Element (Node.Origin.Part_Index).all;
               X : constant Part_Node := Self.Parts.Element (Node.Origin);
            begin
               Result (Index).Origin := Origin.Index;

               if X.List_Extension = 0 then
                  Decl := ((X.Denote, 0), Node.Attr_Name);
               else
                  Decl := ((S.Empty_Universal_String, X.List_Extension),
                           Node.Attr_Name);
               end if;
            end;
         end if;

         if Item.Result = 0 then
            Item.Result := Index;
            Item.Argument_First := Index + 1;
         end if;

         Item.Argument_Last := Index;
         Result (Index).Declaration := Self.Decl_Map.Element (Decl).Index;

         Index := Index + 1;
      end Each;
   begin
      Self.Attributes.Iterate (Each'Access);
   end Copy_Attributes;

   -----------------------
   -- Copy_Declarations --
   -----------------------

   procedure Copy_Declarations
     (Self   : in out Constructor;
      Result : out Declaration_Array)
   is
      Index : Attribute_Declaration_Index := Result'First;

      use Constructor_Nodes, Nodes;

      procedure Each (Cursor : Declaration_Maps.Cursor);

      procedure Each (Cursor : Declaration_Maps.Cursor) is
         Key  : constant Declaration_Key := Declaration_Maps.Key (Cursor);
         Node : constant Declaration_Node :=
           Declaration_Maps.Element (Cursor);
      begin
         Result (Index).Name := Key.Name;
         Result (Index).Index := Index;
         Result (Index).Is_Inherited := Node.Inherited;
         Self.Decl_Map.Insert (Key, Result (Index)'Unchecked_Access);

         if Key.Parent.Non_Terminal.Is_Empty then
            null;
         elsif Self.Terminals.Contains (Key.Parent.Non_Terminal) then
            declare
               Item : Terminal renames
                 Terminal (Self.Terminals.Element
                             (Key.Parent.Non_Terminal).all);
            begin
               if Item.Last_Attribute = 0 then
                  Item.First_Attribute := Index;
               end if;

               Item.Last_Attribute := Index;
            end;
         else
            declare
               Item : Non_Terminal renames
                 Non_Terminal (Self.Non_Terminals.Element
                                 (Key.Parent.Non_Terminal).all);
            begin
               if Item.Last_Attribute = 0 then
                  Item.First_Attribute := Index;
               end if;

               Item.Last_Attribute := Index;
            end;
         end if;

         Index := Index + 1;
      end Each;

   begin
      Self.Declarations.Iterate (Each'Access);
   end Copy_Declarations;

   ----------------
   -- Copy_Rules --
   ----------------

   procedure Copy_Rules
     (Self   : Constructor;
      Result : out Rule_Array)
   is
      Index : Rule_Index := Result'First;

      use Constructor_Nodes, Nodes;

      procedure Each (Cursor : Rule_Maps.Cursor);

      procedure Each (Cursor : Rule_Maps.Cursor) is
         Key  : constant Rule_Key := Rule_Maps.Key (Cursor);
         Prod : Production'Class renames Production'Class
           (Self.Prod_Map.Element (Key.Parent.Production_Index).all);
      begin
         Result (Index).Index := Index;
         Result (Index).Parent := Prod.Index;

         if Prod.Last_Rule = 0 then
            Prod.First_Rule := Index;
         end if;

         Prod.Last_Rule := Index;

         declare
            My : Constructor renames Constructor (Self.Self.all);
         begin
            My.Rules.Replace_Element (Cursor, Result (Index)'Unchecked_Access);

            Index := Index + 1;
         end;
      end Each;
   begin
      Self.Rules.Iterate (Each'Access);
   end Copy_Rules;

end Gela.Grammars.Attributed;
