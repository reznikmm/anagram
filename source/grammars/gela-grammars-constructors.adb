------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Gela.Grammars.Rule_Templates;
with Ada.Wide_Wide_Text_IO;
with Ada.Unchecked_Deallocation;


package body Gela.Grammars.Constructors is

   procedure Fill_Attr_Declarations
     (Self   : in out Constructor'Class;
      Result : in out Grammar;
      Parent : S.Universal_String;
      Attr   : in out Attribute_Declaration_Maps.Map);
   --  Fill Result with attribute declarations from Attr
   --  Collect attribute declaration indexes in Denotes using Parent name.

   procedure Fill_Terminals
     (Self    : in out Constructor'Class;
      Result  : in out Grammar);
   --  Fill Result with terminals from Self. Add their attribute declarations.
   --  Collect terminal indexes in Denotes

   procedure Fill_Non_Terminals
     (Self    : in out Constructor'Class;
      Result  : in out Grammar);
   --     Fill Result with non-terminals from Self.
   --     Add their attribute declarations.
   --     Collect terminal indexes in Denotes

   procedure Fill_Productions
     (Self    : in out Constructor'Class;
      Result  : in out Grammar);
   --  Fill Result with non-terminals from Self. Add their parts and rules.
   --  Collect terminal indexes in Denotes

   procedure Fill_Rule
     (Self   : in out Constructor'Class;
      Result : in out Grammar;
      Item   : Rule_Data);

   procedure Fill_Attr
     (Result : in out Grammar;
      Index  : Attribute_Index;
      Attr   : Attribute_Declaration;
      LHS    : Boolean;
      Part   : Part_Access);

   procedure Join
     (Left  : in out Reference_Maps.Map;
      Right : Reference_Maps.Map);

   procedure Fill_Part
     (Self   : in out Constructor'Class;
      Result : in out Grammar;
      Item   : Part_Access;
      Parent : Production_Index);

   procedure Fill_Production_List
     (Self   : in out Constructor'Class;
      Result : in out Grammar;
      List   : Production_List_Access;
      Parent : Non_Terminal_Count);

   procedure Free is new Ada.Unchecked_Deallocation
     (Production_List_Node, Production_List_Access);

   procedure Free is new Ada.Unchecked_Deallocation
     (Production_Node, Production_Access);

   procedure Free is new Ada.Unchecked_Deallocation (Part_Node, Part_Access);

   ---------
   -- Add --
   ---------

   procedure Add
     (Self : in out Production;
      Item : Part'Class) is
   begin
      Self.Data.Parts.Append (Item.Data);

      case Item.Data.Kind is
         when Terminal_Reference =>
            if not Item.Data.Name.Is_Empty then
               Self.Data.References.Insert (Item.Data.Name, Item.Data);
            end if;

            Self.Data.Parts_Count := Self.Data.Parts_Count + 1;
         when Non_Terminal_Reference | List =>
            if not Item.Data.Name.Is_Empty then
               Self.Data.References.Insert (Item.Data.Name, Item.Data);
            end if;

            Self.Data.Parts_Count := Self.Data.Parts_Count + 1;
         when Option =>
            Self.Data.Prods_Count := Self.Data.Prods_Count
              + Item.Data.List.Prods_Count;
            Self.Data.Parts_Count := Self.Data.Parts_Count
              + Item.Data.List.Parts_Count + 1;

            Join (Self.Data.References, Item.Data.Refs);
      end case;
   end Add;

   ---------
   -- Add --
   ---------

   procedure Add
     (List : in out Production_List;
      Item : Production'Class) is
   begin
      if not Item.Data.Name.Is_Empty and then
        List.Data.Productions.Find_Index (Item.Data) /= 0
      then
         raise Constraint_Error;
      end if;

      List.Data.Productions.Append (Item.Data);
      List.Data.Attr_Count  := List.Data.Attr_Count  + Item.Data.Attr_Count;
      List.Data.Prods_Count := List.Data.Prods_Count + Item.Data.Prods_Count;
      List.Data.Parts_Count := List.Data.Parts_Count + Item.Data.Parts_Count;
   end Add;

   --------------
   -- Complete --
   --------------

   function Complete (Self : in out Constructor) return Grammar is
      procedure Destroy (List : in out Production_List_Access);

      -------------
      -- Destroy --
      -------------

      procedure Destroy (List : in out Production_List_Access) is
      begin
         for X of List.Productions loop
            for Y of X.Parts loop
               if Y.Kind = Option then
                  Destroy (Y.List);
               end if;
               Free (Y);
            end loop;

            Free (X);
         end loop;

         Free (List);
      end Destroy;

      Last_Terminal     : constant Terminal_Count :=
        Terminal_Count (Self.Terminals.Length);
      Last_Non_Terminal : constant Non_Terminal_Count :=
        Non_Terminal_Count (Self.Non_Terminals.Length);
   begin
      return Result : Grammar (Last_Terminal,
                               Last_Non_Terminal,
                               Self.Last_Production,
                               Self.Last_Part,
                               Self.Last_Declaration,
                               Self.Last_Attribute,
                               Self.Last_Rule)
      do
         declare
         begin
            Self.Last_Production := 0;
            Self.Last_Part := 0;
            Self.Last_Declaration := 0;
            Self.Last_Attribute := 0;
            Self.Last_Rule := 0;

            Fill_Terminals (Self, Result);
            Fill_Non_Terminals (Self, Result);
            Fill_Productions (Self, Result);
            Result.Root := 1;

            for Item of Self.Non_Terminals loop
               Destroy (Item.List);
            end loop;
         end;
      end return;
   end Complete;

   ----------------------------------
   -- Create_Attribute_Declaration --
   ----------------------------------

   procedure Create_Attribute_Declaration
     (Self         : in out Constructor;
      Terminal     : S.Universal_String;
      Name         : S.Universal_String;
      Type_Name    : S.Universal_String)
   is
      Next : constant Attribute_Declaration := (999, Name, False, Type_Name);
   begin
      if Self.Terminals (Terminal).Attr.Contains (Name) then
         raise Constraint_Error;
      end if;

      Self.Terminals (Terminal).Attr.Insert (Name, Next);
      Self.Last_Declaration := Self.Last_Declaration + 1;
   end Create_Attribute_Declaration;

   ----------------------------------
   -- Create_Attribute_Declaration --
   ----------------------------------

   procedure Create_Attribute_Declaration
     (Self         : in out Constructor;
      Non_Terminal : S.Universal_String;
      Name         : S.Universal_String;
      Is_Inherited : Boolean;
      Type_Name    : S.Universal_String)
   is
      Next : constant Attribute_Declaration :=
        (999, Name, Is_Inherited, Type_Name);
   begin
      if Self.Non_Terminals (Non_Terminal).Attr.Contains (Name) then
         raise Constraint_Error;
      end if;

      Self.Non_Terminals (Non_Terminal).Attr.Insert (Name, Next);
      Self.Last_Declaration := Self.Last_Declaration + 1;
   end Create_Attribute_Declaration;

   -----------------
   -- Create_List --
   -----------------

   procedure Create_List
     (Self : in out Constructor;
      Name : S.Universal_String;
      List : in out Production_List'Class)
   is
      Next : constant Non_Terminal :=
        (Index       => 999,
         Is_List     => True,
         Name        => Name,
         Attr        => Attribute_Declaration_Maps.Empty_Map,
         List        => List.Data);
   begin
      Self.Non_Terminals.Insert (Name, Next);
      Self.Last_Production := Self.Last_Production + List.Data.Prods_Count;
      Self.Last_Part := Self.Last_Part + List.Data.Parts_Count;
      List.Data := null;
   end Create_List;

   ---------------------------
   -- Create_List_Reference --
   ---------------------------

   function Create_List_Reference
     (Self   : Constructor'Class;
      Name   : S.Universal_String;
      Denote : S.Universal_String)
      return Part
   is
      pragma Unreferenced (Self);

      Next : constant Part_Node :=
        (Index  => 999,
         Kind   => List,
         Name   => Name,
         Denote => Denote);
   begin
      return (Data => new Part_Node'(Next));
   end Create_List_Reference;

   -------------------------
   -- Create_Non_Terminal --
   -------------------------

   procedure Create_Non_Terminal
     (Self : in out Constructor;
      Name : S.Universal_String;
      List : in out Production_List'Class)
   is
      Next : constant Non_Terminal :=
        (Index       => 999,
         Is_List     => False,
         Name        => Name,
         Attr        => Attribute_Declaration_Maps.Empty_Map,
         List        => List.Data);
   begin
      Self.Non_Terminals.Insert (Name, Next);
      Self.Last_Attribute := Self.Last_Attribute + List.Data.Attr_Count;
      Self.Last_Production := Self.Last_Production + List.Data.Prods_Count;
      Self.Last_Part := Self.Last_Part + List.Data.Parts_Count;
      List.Data := null;
   end Create_Non_Terminal;

   -----------------------------------
   -- Create_Non_Terminal_Reference --
   -----------------------------------

   function Create_Non_Terminal_Reference
     (Self   : Constructor'Class;
      Name   : S.Universal_String;
      Denote : S.Universal_String)
      return Part
   is
      pragma Unreferenced (Self);

      Next : constant Part_Node :=
        (Index  => 999,
         Kind   => Non_Terminal_Reference,
         Name   => Name,
         Denote => Denote);
   begin
      return (Data => new Part_Node'(Next));
   end Create_Non_Terminal_Reference;

   -------------------
   -- Create_Option --
   -------------------

   function Create_Option
     (Self  : Constructor'Class;
      Name  : S.Universal_String;
      List  : in out Production_List'Class)
      return Part
   is
      pragma Unreferenced (Self);

      Refs : Reference_Maps.Map;
      X    : Production_Vectors.Vector renames List.Data.Productions;
   begin
      for J in X.First_Index .. X.Last_Index loop
         Join (Refs, X.Element (J).References);
      end loop;

      return Result : constant Part :=
        (Data => new Part_Node'
                (Index => 999,
                 Kind  => Option,
                 Name  => Name,
                 List  => List.Data,
                 Refs  => Refs))
      do
         List.Data := null;
      end return;
   end Create_Option;

   -----------------------
   -- Create_Production --
   -----------------------

   function Create_Production
     (Self   : Constructor'Class;
      Name   : S.Universal_String)
      return Production
   is
      pragma Unreferenced (Self);
   begin
      return (Data => new Production_Node'
                (Index       => 999,
                 Name        => Name,
                 Parts       => Part_Vectors.Empty_Vector,
                 Rules       => Rule_Vectors.Empty_Vector,
                 References  => Reference_Maps.Empty_Map,
                 Attr_Count  => 0,
                 Prods_Count => 1,
                 Parts_Count => 0,
                 Precedence  => Undefined_Precedence));
   end Create_Production;

   ----------------------------
   -- Create_Production_List --
   ----------------------------

   function Create_Production_List
     (Self : Constructor'Class)
      return Production_List
   is
      pragma Unreferenced (Self);
   begin
      return (Data => new Production_List_Node'
                (Productions => Production_Vectors.Empty_Vector,
                 Attr_Count  => 0,
                 Prods_Count => 0,
                 Parts_Count => 0));
   end Create_Production_List;

   -----------------
   -- Create_Rule --
   -----------------

   procedure Create_Rule
     (Self         : in out Constructor;
      Non_Terminal : S.Universal_String;
      Production   : S.Universal_String;
      Text         : S.Universal_String)
   is
      use type S.Universal_String;

      List     : Production_List_Access;
      Template : constant Rule_Templates.Rule_Template :=
        Rule_Templates.Create (Text);
   begin
      List := Self.Non_Terminals.Element (Non_Terminal).List;

      for Prod of List.Productions loop
         if Prod.Name = Production then
            Prod.Rules.Append
              ((Text         => Text,
                Non_Terminal => Non_Terminal,
                Production   => Prod));
            Self.Last_Rule := Self.Last_Rule + 1;
            Self.Last_Attribute := Self.Last_Attribute +
              Attribute_Count (Template.Count);

            return;
         end if;
      end loop;
   end Create_Rule;

   ---------------------
   -- Create_Terminal --
   ---------------------

   procedure Create_Terminal
     (Self  : in out Constructor;
      Image : S.Universal_String;
      Prec  : Precedence_Value := Undefined_Precedence)
   is
      Next : constant Terminal :=
        (Index       => 999,
         Name        => Image,
         Attr        => Attribute_Declaration_Maps.Empty_Map,
         Prec        => Prec);
   begin
      Self.Terminals.Insert (Image, Next);
   end Create_Terminal;

   -------------------------------
   -- Create_Terminal_Reference --
   -------------------------------

   function Create_Terminal_Reference
     (Self  : Constructor'Class;
      Name  : S.Universal_String;
      Image : S.Universal_String)
      return Part
   is
      pragma Unreferenced (Self);

      Next : constant Part_Node :=
        (Index => 999,
         Kind  => Terminal_Reference,
         Name  => Name,
         Image => Image);
   begin
      return (Data => new Part_Node'(Next));
   end Create_Terminal_Reference;

   ----------------
   -- Equal_Name --
   ----------------

   function Equal_Name (Left, Right : Production_Access) return Boolean is
      use type S.Universal_String;
   begin
      return Left.Name = Right.Name;
   end Equal_Name;

   ----------------------------
   -- Fill_Attr_Declarations --
   ----------------------------

   procedure Fill_Attr_Declarations
     (Self   : in out Constructor'Class;
      Result : in out Grammar;
      Parent : S.Universal_String;
      Attr   : in out Attribute_Declaration_Maps.Map)
   is
      pragma Unreferenced (Parent);
   begin
      for Item of Attr loop
         Self.Last_Declaration := Self.Last_Declaration + 1;
         Item.Index := Self.Last_Declaration;
         Result.Declaration (Self.Last_Declaration).Name := Item.Name;
         Result.Declaration (Self.Last_Declaration).Type_Name :=
           Item.Type_Name;
         Result.Declaration (Self.Last_Declaration).Index :=
           Self.Last_Declaration;
         Result.Declaration (Self.Last_Declaration).Is_Inherited :=
           Item.Is_Inherited;
      end loop;
   end Fill_Attr_Declarations;

   ------------------------
   -- Fill_Non_Terminals --
   ------------------------

   procedure Fill_Non_Terminals
     (Self    : in out Constructor'Class;
      Result  : in out Grammar)
   is
      Last_Non_Terminal : Non_Terminal_Count := 1;
   begin
      for Item of Self.Non_Terminals loop
         Item.Index := Last_Non_Terminal;

         Result.Non_Terminal (Last_Non_Terminal).Name := Item.Name;
         Result.Non_Terminal (Last_Non_Terminal).Index :=
           Last_Non_Terminal;
         Result.Non_Terminal (Last_Non_Terminal).Is_List := Item.Is_List;
         Result.Non_Terminal (Last_Non_Terminal).First_Attribute :=
           Self.Last_Declaration + 1;
         Result.Non_Terminal (Last_Non_Terminal).Last_Attribute :=
           Self.Last_Declaration +
             Attribute_Declaration_Count (Item.Attr.Length);

         Fill_Attr_Declarations (Self, Result, Item.Name, Item.Attr);

         Last_Non_Terminal := Last_Non_Terminal + 1;
      end loop;
   end Fill_Non_Terminals;

   ---------------
   -- Fill_Part --
   ---------------

   procedure Fill_Part
     (Self   : in out Constructor'Class;
      Result : in out Grammar;
      Item   : Part_Access;
      Parent : Production_Index) is
   begin
      Self.Last_Part := Self.Last_Part + 1;

      declare
         P : Grammars.Part renames Result.Part (Self.Last_Part);
      begin
         Item.Index := Self.Last_Part;
         P.Name := Item.Name;
         P.Index := Self.Last_Part;
         P.Parent := Parent;
         P.Is_Terminal_Reference     := Item.Kind = Terminal_Reference;
         P.Is_Non_Terminal_Reference := Item.Kind = Non_Terminal_Reference;
         P.Is_List                   := Item.Kind = List;
         P.Is_Option                 := Item.Kind = Option;

         case Item.Kind is
            when Terminal_Reference =>
               if Self.Terminals.Contains (Item.Image) then
                  P.Denoted_Terminal :=
                    Self.Terminals.Element (Item.Image).Index;
                  P.Denoted_Non_Terminal := 0;
               else
                  raise Constraint_Error;
               end if;

            when Non_Terminal_Reference | List =>
               if Self.Non_Terminals.Contains (Item.Denote) then
                  P.Denoted_Non_Terminal :=
                    Self.Non_Terminals.Element (Item.Denote).Index;
                  P.Denoted_Terminal := 0;
               else
                  Ada.Wide_Wide_Text_IO.Put_Line
                    ("Not defined: " & Item.Denote.To_Wide_Wide_String);
                  raise Constraint_Error;
               end if;

            when Option =>
               null;
         end case;
      end;
   end Fill_Part;

   --------------------------
   -- Fill_Production_List --
   --------------------------

   procedure Fill_Production_List
     (Self   : in out Constructor'Class;
      Result : in out Grammar;
      List   : Production_List_Access;
      Parent : Non_Terminal_Count) is
   begin
      for P of List.Productions loop
         Self.Last_Production := Self.Last_Production + 1;
         P.Index := Self.Last_Production;

         Result.Production (Self.Last_Production).Name := P.Name;
         Result.Production (Self.Last_Production).Index :=
           Self.Last_Production;
         Result.Production (Self.Last_Production).First := Self.Last_Part + 1;
         Result.Production (Self.Last_Production).Last := Self.Last_Part +
           P.Parts.Last_Index;
         Result.Production (Self.Last_Production).Parent := Parent;
         Result.Production (Self.Last_Production).Precedence := P.Precedence;

         for Part of P.Parts loop
            Fill_Part (Self, Result, Part, Self.Last_Production);
         end loop;
      end loop;

      for P of List.Productions loop
         for Part of P.Parts loop
            if Part.Kind = Option then
               Result.Part (Part.Index).First := Self.Last_Production + 1;
               Result.Part (Part.Index).Last := Self.Last_Production
                 + Part.List.Productions.Last_Index;
               Fill_Production_List (Self, Result, Part.List, Parent => 0);
            end if;
         end loop;

         Result.Production (P.Index).First_Rule := Self.Last_Rule + 1;
         Result.Production (P.Index).Last_Rule  := Self.Last_Rule
           + P.Rules.Last_Index;

         for R of P.Rules loop
            Fill_Rule (Self, Result, R);
         end loop;
      end loop;
   end Fill_Production_List;

   ----------------------
   -- Fill_Productions --
   ----------------------

   procedure Fill_Productions
     (Self    : in out Constructor'Class;
      Result  : in out Grammar) is
   begin
      for Item of Self.Non_Terminals loop
         Result.Non_Terminal (Item.Index).First := Self.Last_Production + 1;
         Result.Non_Terminal (Item.Index).Last := Self.Last_Production
           + Item.List.Productions.Last_Index;
         Fill_Production_List (Self, Result, Item.List, Parent => Item.Index);
      end loop;
   end Fill_Productions;

   ---------------
   -- Fill_Rule --
   ---------------

   procedure Fill_Rule
     (Self   : in out Constructor'Class;
      Result : in out Grammar;
      Item   : Rule_Data)
   is
      use type S.Universal_String;
      LHS      : Boolean;
      Part     : Part_Access;
      Attr     : Attribute_Declaration;
      Name     : S.Universal_String;
      Origin   : S.Universal_String;
      Denote   : S.Universal_String;
      LHS_Attr : Natural := 0;
      Template : constant Rule_Templates.Rule_Template :=
        Rule_Templates.Create (Item.Text);
   begin
      Self.Last_Rule := Self.Last_Rule + 1;
      --  Reserve space for result attr
      Self.Last_Attribute := Self.Last_Attribute + 1;
      Result.Rule (Self.Last_Rule).Index := Self.Last_Rule;
      Result.Rule (Self.Last_Rule).Text := Item.Text;
      Result.Rule (Self.Last_Rule).Result := Self.Last_Attribute;
      Result.Rule (Self.Last_Rule).First_Argument := Self.Last_Attribute + 1;
      Result.Rule (Self.Last_Rule).Last_Argument := Self.Last_Attribute
        + Attribute_Count (Template.Count - 1);
      Result.Rule (Self.Last_Rule).Parent := Item.Production.Index;

      for J in 1 .. Template.Count loop
         Name   := Template.Attribute_Name (J);
         Origin := Template.Part_Name (J);

         LHS := Item.Non_Terminal = Origin;

         if LHS then
            Denote := Item.Non_Terminal;
            Attr := Self.Non_Terminals.Element (Denote).Attr.Element (Name);
         else
            if Item.Production.References.Contains (Origin) then
               Part := Item.Production.References.Element (Origin);

               case Part.Kind is
                  when Terminal_Reference =>
                     Denote := Part.Image;
                     Attr :=
                       Self.Terminals.Element (Denote).Attr.Element (Name);
                  when Non_Terminal_Reference | List =>
                     Denote := Part.Denote;
                     Attr :=
                       Self.Non_Terminals.Element (Denote).Attr.Element (Name);
                  when Option =>
                     raise Constraint_Error;
               end case;
            else
               raise Constraint_Error;
            end if;
         end if;

         if LHS xor Attr.Is_Inherited then
            if LHS_Attr = 0 then
               LHS_Attr := J;
               Fill_Attr
                 (Result,
                  Result.Rule (Self.Last_Rule).Result,
                  Attr,
                  LHS,
                  Part);
            else
               raise Constraint_Error;
            end if;
         else
            Self.Last_Attribute := Self.Last_Attribute + 1;
            Fill_Attr (Result, Self.Last_Attribute, Attr, LHS, Part);
         end if;

      end loop;

      if LHS_Attr = 0 then
         raise Constraint_Error;
      end if;
   end Fill_Rule;

   ---------------
   -- Fill_Attr --
   ---------------

   procedure Fill_Attr
     (Result : in out Grammar;
      Index  : Attribute_Index;
      Attr   : Attribute_Declaration;
      LHS    : Boolean;
      Part   : Part_Access) is
   begin
      Result.Attribute (Index).Index := Index;
      Result.Attribute (Index).Declaration := Attr.Index;

      if LHS then
         Result.Attribute (Index).Origin := 0;
      else
         Result.Attribute (Index).Origin := Part.Index;
      end if;
   end Fill_Attr;

   --------------------
   -- Fill_Terminals --
   --------------------

   procedure Fill_Terminals
     (Self   : in out Constructor'Class;
      Result : in out Grammar)
   is
      Last_Terminal : Terminal_Index := 1;
   begin
      for Item of Self.Terminals loop
         Item.Index := Last_Terminal;
         Result.Terminal (Last_Terminal).Image := Item.Name;
         Result.Terminal (Last_Terminal).Index := Last_Terminal;
         Result.Terminal (Last_Terminal).First_Attribute :=
           Self.Last_Declaration + 1;
         Result.Terminal (Last_Terminal).Last_Attribute :=
           Self.Last_Declaration +
             Attribute_Declaration_Count (Item.Attr.Length);
         Result.Terminal (Last_Terminal).Precedence := Item.Prec;

         Fill_Attr_Declarations (Self, Result, Item.Name, Item.Attr);

         Last_Terminal := Last_Terminal + 1;
      end loop;
   end Fill_Terminals;

   ----------
   -- Join --
   ----------

   procedure Join
     (Left  : in out Reference_Maps.Map;
      Right : Reference_Maps.Map)
   is
      use League.Strings;
      Pos : Reference_Maps.Cursor := Right.First;
   begin
      while Reference_Maps.Has_Element (Pos) loop
         declare
            X : constant S.Universal_String := Reference_Maps.Key (Pos);
            Y : constant Part_Access := Reference_Maps.Element (Pos);
         begin
            if Left.Contains (X) then
               if Left.Element (X).Denote /= Y.Denote then
                  Ada.Wide_Wide_Text_IO.Put_Line (X.To_Wide_Wide_String);
                  raise Constraint_Error;
               end if;
            else
               Left.Insert (X, Y);
            end if;

            Reference_Maps.Next (Pos);
         end;
      end loop;
   end Join;

   --------------------
   -- Set_Precedence --
   --------------------

   procedure Set_Precedence
     (Self         : in out Constructor;
      Non_Terminal : S.Universal_String;
      Production   : S.Universal_String;
      Precedence   : Precedence_Value)
   is
      use type S.Universal_String;

      List     : Production_List_Access;
   begin
      List := Self.Non_Terminals.Element (Non_Terminal).List;

      for Prod of List.Productions loop
         if Prod.Name = Production then
            Prod.Precedence := Precedence;
            return;
         end if;
      end loop;

      raise Constraint_Error;
   end Set_Precedence;

   ------------------
   -- To_Augmented --
   ------------------

   function To_Augmented (Input : Grammar) return Grammar is
   begin
      return Result : Grammar
        (Input.Last_Terminal,
         Input.Last_Non_Terminal + 1,
         Input.Last_Production + 1,
         Input.Last_Part + 1,
         Input.Last_Declaration,
         Input.Last_Attribute,
         Input.Last_Rule)
      do
         Result.Root := Result.Last_Non_Terminal;

         Result.Terminal := Input.Terminal;

         Result.Non_Terminal (Input.Non_Terminal'Range) := Input.Non_Terminal;

         declare
            T : Grammars.Non_Terminal renames Result.Non_Terminal
              (Result.Last_Non_Terminal);
         begin
            T := (Name => Input.Non_Terminal (Input.Root).Name & "'",
                  Index => Result.Last_Non_Terminal,
                  First => Result.Last_Production,
                  Last => Result.Last_Production,
                  Is_List => False,
                  First_Attribute => 1,
                  Last_Attribute => 0);
         end;

         Result.Production (Input.Production'Range) := Input.Production;

         declare
            T : Grammars.Production renames
              Result.Production (Result.Last_Production);
         begin
            T := (Name => League.Strings.Empty_Universal_String,
                  Index => Result.Last_Production,
                  Parent => Result.Root,
                  First => Result.Last_Part,
                  Last => Result.Last_Part,
                  First_Rule => 1,
                  Last_Rule => 0,
                  Precedence => Undefined_Precedence);
         end;

         Result.Part (Input.Part'Range) := Input.Part;

         declare
            NT : Grammars.Non_Terminal renames Input.Non_Terminal (Input.Root);
            T : Grammars.Part renames Result.Part (Result.Last_Part);
         begin
            T := (Name => NT.Name,
                  Index => Result.Last_Part,
                  Parent => Result.Last_Production,
                  Is_Terminal_Reference => False,
                  Is_Non_Terminal_Reference => True,
                  Is_List => False,
                  Is_Option => False,
                  Denoted_Terminal => 0,
                  Denoted_Non_Terminal => NT.Index,
                  First => 1,
                  Last => 0);
         end;

         Result.Declaration (Input.Declaration'Range) := Input.Declaration;
         Result.Attribute (Input.Attribute'Range) := Input.Attribute;
         Result.Rule (Input.Rule'Range) := Input.Rule;
         Result.With_List := Input.With_List;
      end return;
   end To_Augmented;

end Gela.Grammars.Constructors;
