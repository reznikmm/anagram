------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Gela.Grammars.Constructors;

package Gela.Grammars.Attributed is

   type Attribute_Declaration_Count is new Natural;

   subtype Attribute_Declaration_Index is Attribute_Declaration_Count
     range 1 .. Attribute_Declaration_Count'Last;

   type Attribute_Count is new Natural;

   subtype Attribute_Index is Attribute_Count
     range 1 .. Attribute_Count'Last;

   type Rule_Count is new Natural;

   subtype Rule_Index is Rule_Count range 1 .. Rule_Count'Last;

   type Attribute_Declaration is tagged limited private;

   function Is_Inherited (Self : access Attribute_Declaration) return Boolean;

   function Name
     (Self : access Attribute_Declaration)
     return S.Universal_String;

   function Index
     (Self : access Attribute_Declaration)
     return Attribute_Declaration_Index;

   type Attribute is tagged limited private;

   function Is_Left_Hand_Side (Self : access Attribute) return Boolean;
   function Index             (Self : access Attribute) return Attribute_Index;
   function Origin            (Self : access Attribute) return Part_Count;

   function Declaration
     (Self : access Attribute)
     return Attribute_Declaration_Index;

   type Rule is tagged limited private;

   function Index          (Self : access Rule) return Rule_Index;
   function Result         (Self : access Rule) return Attribute_Index;
   function Argument_First (Self : access Rule) return Attribute_Index;
   function Argument_Last  (Self : access Rule) return Attribute_Count;
   function Parent         (Self : access Rule) return Production_Index;

   type Terminal is new Gela.Grammars.Terminal with private;

   function First (Self : access Terminal) return Attribute_Declaration_Index;
   function Last  (Self : access Terminal) return Attribute_Declaration_Count;

   type Non_Terminal is new Gela.Grammars.Non_Terminal with private;

   function First
     (Self : access Non_Terminal)
     return Attribute_Declaration_Index;

   function Last
     (Self : access Non_Terminal)
     return Attribute_Declaration_Count;

   type Production is new Gela.Grammars.Production with private;

   function First (Self : access Production) return Rule_Index;
   function Last  (Self : access Production) return Rule_Count;

   type Declaration_Array is array (Attribute_Declaration_Index range <>) of
     aliased Attribute_Declaration;

   type Attribute_Array is array (Attribute_Index range <>) of
     aliased Attribute;

   type Rule_Array is array (Rule_Index range <>) of aliased Rule;
   type Terminal_Array is array (Terminal_Index range <>) of aliased Terminal;
   type Non_Terminal_Array is array (Non_Terminal_Index range <>) of
     aliased Non_Terminal;
   type Production_Array is array (Production_Index range <>) of
     aliased Production;

   type Grammar
     (Last_Terminal     : Terminal_Count;
      Last_Non_Terminal : Non_Terminal_Count;
      Last_Production   : Production_Count;
      Last_Part         : Part_Count;
      Last_Declaration  : Attribute_Declaration_Count;
      Last_Attribute    : Attribute_Count;
      Last_Rule         : Rule_Count) is
   tagged limited record
      Terminal     : Terminal_Array     (1 .. Last_Terminal);
      Non_Terminal : Non_Terminal_Array (1 .. Last_Non_Terminal);
      Production   : Production_Array   (1 .. Last_Production);
      Part         : Part_Array         (1 .. Last_Part);
      Declaration  : Declaration_Array  (1 .. Last_Declaration);
      Attribute    : Attribute_Array    (1 .. Last_Attribute);
      Rule         : Rule_Array         (1 .. Last_Rule);
   end record;

   type Constructor is abstract
     new Gela.Grammars.Constructors.Constructor with private;

private

   type Attribute_Declaration is tagged limited record
      Name  : S.Universal_String;
      Index : Attribute_Declaration_Index;
      Is_Inherited : Boolean;
   end record;

   type Attribute is tagged limited record
      Index             : Attribute_Index;
      Origin            : Part_Count;
      Declaration       : Attribute_Declaration_Index;
   end record;

   type Rule is tagged limited record
      Index          : Rule_Index;
      Result         : Attribute_Count := 0;
      Argument_First : Attribute_Index;
      Argument_Last  : Attribute_Count;
      Parent         : Production_Index;
   end record;

   type Terminal is new Gela.Grammars.Terminal with record
      First_Attribute : Attribute_Declaration_Index := 1;
      Last_Attribute  : Attribute_Declaration_Count := 0;
   end record;

   type Non_Terminal is new Gela.Grammars.Non_Terminal with record
      First_Attribute : Attribute_Declaration_Index := 1;
      Last_Attribute  : Attribute_Declaration_Count := 0;
   end record;

   type Production is new Gela.Grammars.Production with record
      First_Rule : Rule_Index := 1;
      Last_Rule  : Rule_Count := 0;
   end record;

   package Nodes is
      use Constructor_Nodes;

      type Declaration_Key is record
         Parent  : Alternative_Key;
         Name    : S.Universal_String;
      end record;

      function "<" (Left, Right : Declaration_Key) return Boolean;

      type Declaration_Node is record
         Inherited : Boolean;
      end record;

      type Rule_Key is record
         Parent     : Production_Key;
         Rule_Index : Positive;
      end record;

      function "<" (Left, Right : Rule_Key) return Boolean;

      type Attribute_Key is record
         Parent     : Rule_Key;
         Attr_Index : Natural;  --  0 -- for result, 1+ -- arg
      end record;

      function "<" (Left, Right : Attribute_Key) return Boolean;

      type Attribute_Node is record
         Origin    : Part_Key;
         Attr_Name : S.Universal_String;
      end record;

      package Declaration_Maps is new Ada.Containers.Ordered_Maps
        (Declaration_Key, Declaration_Node);

      type Rule_Access is access all Rule;

      package Rule_Maps is new Ada.Containers.Ordered_Maps
        (Rule_Key, Rule_Access);

      package Attribute_Maps is new Ada.Containers.Ordered_Maps
        (Attribute_Key, Attribute_Node);

      type Declaration_Access is access all Attribute_Declaration;

      package Decl_Index_Maps is new Ada.Containers.Ordered_Maps
        (Declaration_Key, Declaration_Access);

      procedure Copy_Terminals is new Constructor_Nodes.Generic_Copy_Terminals
        (Terminal, Terminal_Array);

      procedure Copy_Non_Terminals is
        new Constructor_Nodes.Generic_Copy_Non_Terminals
          (Non_Terminal, Non_Terminal_Array);

      procedure Copy_Productions is
        new Constructor_Nodes.Generic_Copy_Productions
          (Production, Production_Array);

   end Nodes;

   type Constructor is abstract new Gela.Grammars.Constructors.Constructor
     with record
        Declarations    : Nodes.Declaration_Maps.Map;
        Rules           : Nodes.Rule_Maps.Map;
        Attributes      : Nodes.Attribute_Maps.Map;
        Decl_Map        : Nodes.Decl_Index_Maps.Map;
   end record;

   procedure Copy_Declarations
     (Self   : in out Constructor;
      Result : out Declaration_Array);

   procedure Copy_Rules
     (Self   : Constructor;
      Result : out Rule_Array);

   procedure Copy_Attributes
     (Self   : Constructor;
      Result : out Attribute_Array);

end Gela.Grammars.Attributed;
