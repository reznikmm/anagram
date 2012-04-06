------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

package body Gela.Grammars.Attributed.Constructors is

   ----------------------------------
   -- Create_Attribute_Declaration --
   ----------------------------------

   procedure Create_Attribute_Declaration
     (Self      : in out Constructor;
      Name      : S.Universal_String;
      Type_Name : S.Universal_String;
      Terminal  : S.Universal_String)
   is
      Key : Nodes.Declaration_Key;
   begin
      Key := ((Terminal, 0), Name);
      Self.Declarations.Insert
        (Key, (Inherited => False, Type_Name => Type_Name));
   end Create_Attribute_Declaration;

   ------------------------------
   -- Set_Current_Non_Terminal --
   ------------------------------

   procedure Set_Current_Non_Terminal
     (Self      : in out Constructor;
      Name      : S.Universal_String)
   is
   begin
      Self.Last_Production := ((Name, 0), 1);
   end Set_Current_Non_Terminal;

   ----------------------------------
   -- Create_Attribute_Declaration --
   ----------------------------------

   procedure Create_Attribute_Declaration
     (Self      : in out Constructor;
      Name      : S.Universal_String;
      Type_Name : S.Universal_String;
      Inherited : Boolean)
   is
      Key : Nodes.Declaration_Key;
   begin
      Key := (Self.Last_Production.Parent, Name);
      Self.Declarations.Insert
        (Key, (Inherited => Inherited, Type_Name => Type_Name));
   end Create_Attribute_Declaration;

   --------------------
   -- Set_Production --
   --------------------

   procedure Set_Production
     (Self      : in out Constructor;
      Name      : S.Universal_String)
   is
      Index : Natural := 0;
   begin
      Index := Self.Find_Production (Name);
      Self.Last_Production := (Self.Last_Production.Parent, Index);
   end Set_Production;

   ---------------------
   -- Find_Production --
   ---------------------

   function Find_Production
     (Self : Constructor;
      Name : S.Universal_String)
      return Positive
   is
      use Constructor_Nodes.Production_Maps;
      use type Constructor_Nodes.Alternative_Key;
      use type S.Universal_String;

      Index : Natural := 0;
      Pos   : Cursor := Self.Productions.First;
   begin
      while Has_Element (Pos) loop
         if Key (Pos).Parent = Self.Last_Production.Parent and then
           Element (Pos).Name = Name
         then
            Index := Key (Pos).Production_Index;
            exit;
         end if;

         Pos := Next (Pos);
      end loop;

      return Index;
   end Find_Production;

   -----------------
   -- Create_Rule --
   -----------------

   procedure Create_Rule
     (Self   : in out Constructor;
      Result : S.Universal_String;
      Text   : S.Universal_String) is
   begin
      Self.Last_Rule :=
        (Self.Last_Production, Integer (Self.Rules.Length) + 1);
      Self.Rules.Insert (Self.Last_Rule, (null, Text));
      Self.Attributes.Insert
        ((Self.Last_Rule, 0), (Origin => (Parent => <>, Part_Index => 0),
                    Attr_Name => Result));
   end Create_Rule;

   -----------------
   -- Create_Rule --
   -----------------

   procedure Create_Rule
     (Self   : in out Constructor;
      Part   : S.Universal_String;
      Result : S.Universal_String;
      Text   : S.Universal_String) is
   begin
      Self.Last_Rule :=
        (Self.Last_Production, Integer (Self.Rules.Length) + 1);
      Self.Rules.Insert (Self.Last_Rule,  (null, Text));
      Self.Attributes.Insert
        ((Self.Last_Rule, 0),
         (Origin => (Parent => Self.Last_Production,
                     Part_Index => Self.Find_Part (Part).Part_Index),
          Attr_Name => Result));
   end Create_Rule;

   ---------------------
   -- Create_Argument --
   ---------------------

   procedure Create_Argument
     (Self      : in out Constructor;
      Name      : S.Universal_String)
   is
      Key : constant Nodes.Attribute_Key :=
        (Self.Last_Rule, Natural (Self.Attributes.Length) + 1);
   begin
      Self.Attributes.Insert
        (Key, (Origin => (Parent => Self.Last_Production,
                          Part_Index => 0),
               Attr_Name => Name));
   end Create_Argument;

   ---------------------
   -- Create_Argument --
   ---------------------

   procedure Create_Argument
     (Self      : in out Constructor;
      Name      : S.Universal_String;
      Part      : S.Universal_String)
   is
      Key : constant Nodes.Attribute_Key :=
        (Self.Last_Rule, Natural (Self.Attributes.Length) + 1);
   begin
      Self.Attributes.Insert
        (Key, (Origin => (Parent => Self.Last_Production,
                          Part_Index => Self.Find_Part (Part).Part_Index),
               Attr_Name => Name));
   end Create_Argument;

   --------------
   -- Complete --
   --------------

   function Complete
     (Self : Constructor)
      return Gela.Grammars.Attributed.Grammar
   is
      --  procedure New_Part
      --    (Node   : Constructor_Nodes.Part_Node;
      --     Result : in out Part'Class) is
      --  begin
      --     Gela.Grammars.Constructor_Nodes.New_Part (Node, Result);
      --  end New_Part;

      procedure Copy_Attr_Parts is
        new Constructor_Nodes.Generic_Copy_Parts
          (Part, Part_Array, Gela.Grammars.Constructor_Nodes.New_Part);

      Decls : constant Attribute_Declaration_Count :=
        Attribute_Declaration_Count (Self.Declarations.Length);
   begin
      return Result : Gela.Grammars.Attributed.Grammar
        (Last_Terminal     => Terminal_Count (Self.Terminals.Length),
         Last_Non_Terminal => Non_Terminal_Count (Self.Non_Terminals.Length),
         Last_Production   => Production_Count (Self.Productions.Length),
         Last_Part         => Part_Count (Self.Parts.Length),
         Last_Declaration  => Decls,
         Last_Attribute    => Attribute_Count (Self.Attributes.Length),
         Last_Rule         => Rule_Count (Self.Rules.Length))
      do
         Nodes.Copy_Terminals (Self.Self.all, Result.Terminal);
         Nodes.Copy_Non_Terminals (Self.Self.all, Result.Non_Terminal);
         Nodes.Copy_Productions (Self.Self.all, Result.Production);

         Copy_Attr_Parts
           (Self.Self.all,
            Result.Part);

         Constructor (Self.Self.all).Copy_Declarations (Result.Declaration);

         Self.Copy_Rules (Result.Rule);

         Self.Copy_Attributes (Result.Attribute);

         Result.Root := Self.Non_Terminals.Element (Self.Root).Index;
      end return;
   end Complete;

end Gela.Grammars.Attributed.Constructors;
