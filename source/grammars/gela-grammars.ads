------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with League.Strings;
private with Ada.Containers.Ordered_Maps;

package Gela.Grammars is
   package S renames League.Strings;

   type Terminal_Count is new Natural;
   type Non_Terminal_Count is new Natural;
   type Production_Count is new Natural;
   type Part_Count is new Natural;

   subtype Terminal_Index is Terminal_Count range 1 .. Terminal_Count'Last;

   subtype Non_Terminal_Index is Non_Terminal_Count
     range 1 .. Non_Terminal_Count'Last;

   subtype Production_Index is Production_Count
     range 1 .. Production_Count'Last;

   subtype Part_Index is Part_Count range 1 .. Part_Count'Last;

   type Terminal is tagged limited private;
   function Image (Self : access Terminal) return S.Universal_String;
   function Index (Self : access Terminal) return Terminal_Index;

   type Non_Terminal is tagged limited private;
   function Name  (Self : access Non_Terminal) return S.Universal_String;
   function Index (Self : access Non_Terminal) return Non_Terminal_Index;
   function First (Self : access Non_Terminal) return Production_Index;
   function Last  (Self : access Non_Terminal) return Production_Count;

   type Production is tagged limited private;
   function Name  (Self : access Production) return S.Universal_String;
   function Index (Self : access Production) return Production_Index;
   function First (Self : access Production) return Part_Index;
   function Last  (Self : access Production) return Part_Count;

   type Part is tagged limited private;
   function Name  (Self : access Part) return S.Universal_String;
   function Index (Self : access Part) return Part_Index;
   function Is_Terminal_Reference     (Self : access Part) return Boolean;
   function Is_Non_Terminal_Reference (Self : access Part) return Boolean;
   function Denote (Self : access Part) return Terminal_Count;
   function Denote (Self : access Part) return Non_Terminal_Count;

   type Terminal_Array is array (Terminal_Index range <>) of aliased Terminal;

   type Non_Terminal_Array is array (Non_Terminal_Index range <>) of
     aliased Non_Terminal;

   type Production_Array is array (Production_Index range <>) of
     aliased Production;

   type Part_Array is array (Part_Index range <>) of aliased Part;

   type Grammar
     (Last_Terminal     : Terminal_Count;
      Last_Non_Terminal : Non_Terminal_Count;
      Last_Production   : Production_Count;
      Last_Part         : Part_Count) is
   tagged limited record
      Root         : Non_Terminal_Index;
      Terminal     : Terminal_Array     (1 .. Last_Terminal);
      Non_Terminal : Non_Terminal_Array (1 .. Last_Non_Terminal);
      Production   : Production_Array   (1 .. Last_Production);
      Part         : Part_Array         (1 .. Last_Part);
   end record;

   function Find
     (Self  : Grammar;
      Image : S.Universal_String)
     return Terminal_Count;

   function Find
     (Self : Grammar;
      Name : S.Universal_String)
     return Non_Terminal_Count;

   type Constructor_Base is abstract tagged limited private;

private

   type Terminal is tagged limited record
      Image : S.Universal_String;
      Index : Terminal_Index;
   end record;

   type Non_Terminal is tagged limited record
      Name  : S.Universal_String;
      Index : Non_Terminal_Index;
      First : Production_Index;
      Last  : Production_Count;
   end record;

   type Production is tagged limited record
      Name  : S.Universal_String;
      Index : Production_Index;
      First : Part_Index;
      Last  : Part_Count;
   end record;

   type Part is tagged limited record
      Name                      : S.Universal_String;
      Index                     : Part_Index;
      Is_Terminal_Reference     : Boolean;
      Is_Non_Terminal_Reference : Boolean;
      Denoted_Terminal          : Terminal_Count;
      Denoted_Non_Terminal      : Non_Terminal_Count;
   end record;

   package Constructor_Nodes is

      type Alternative_Key is record
         Non_Terminal      : S.Universal_String;
         Extension         : Natural;
      end record;

      function "<" (Left, Right : Alternative_Key) return Boolean;

      type Production_Key is record
         Parent            : Alternative_Key;
         Production_Index  : Positive;
      end record;

      function "<" (Left, Right : Production_Key) return Boolean;

      type Production_Node is record
         Name : S.Universal_String;
      end record;

      type Part_Key is record
         Parent     : Production_Key;
         Part_Index : Natural;
      end record;

      function "<" (Left, Right : Part_Key) return Boolean;

      type Part_Node is record
         Is_Terminal       : Boolean;
         Name              : S.Universal_String;
         Denote            : S.Universal_String;
         List_Extension    : Natural;
         Option_Extension  : Natural;
      end record;

      use type S.Universal_String;

      type Terminal_Access is access all Terminal'Class;

      package Terminal_Maps is new Ada.Containers.Ordered_Maps
        (S.Universal_String, Terminal_Access);

      type Non_Terminal_Access is access all Non_Terminal'Class;

      package Non_Terminal_Maps is new Ada.Containers.Ordered_Maps
        (S.Universal_String, Non_Terminal_Access);

      package Production_Maps is new Ada.Containers.Ordered_Maps
        (Production_Key, Production_Node);

      package Part_Maps is new Ada.Containers.Ordered_Maps
        (Part_Key, Part_Node);

      type Production_Access is access all Production'Class;

      package Prod_Index_Maps is new Ada.Containers.Ordered_Maps
        (Positive, Production_Access);

      type Part_Access is access all Part'Class;

      package Part_Index_Maps is new Ada.Containers.Ordered_Maps
        (Positive, Part_Access);

      package Extension_Maps is new Ada.Containers.Ordered_Maps
        (Positive, Part_Index);

      type Constructor_Node is abstract tagged limited record
         Self            : access Constructor_Node'Class :=
           Constructor_Node'Unchecked_Access;
         Terminals       : Terminal_Maps.Map;
         Non_Terminals   : Non_Terminal_Maps.Map;
         Productions     : Production_Maps.Map;
         Parts           : Part_Maps.Map;
         Last_Production : Production_Key;
         Prod_Map        : Prod_Index_Maps.Map;
         Part_Map        : Part_Index_Maps.Map;
         Ext_Map         : Extension_Maps.Map;
      end record;

      generic
         type Terminal_Extention is new Terminal with private;
         type Terminal_Extention_Array is array (Terminal_Index range <>) of
           aliased Terminal_Extention;
      procedure Generic_Copy_Terminals
        (Self   : in out Constructor_Node'Class;
         Result : out Terminal_Extention_Array);

      generic
         type Non_Terminal_Extention is new Non_Terminal with private;
         type Non_Terminal_Extention_Array is
           array (Non_Terminal_Index range <>) of aliased
             Non_Terminal_Extention;
      procedure Generic_Copy_Non_Terminals
        (Self   : in out Constructor_Node'Class;
         Result : out Non_Terminal_Extention_Array);

      generic
         type Production_Extention is new Production with private;
         type Production_Extention_Array is
           array (Production_Index range <>) of aliased
             Production_Extention;
      procedure Generic_Copy_Productions
        (Self          : in out Constructor_Node'Class;
         Result        : out Production_Extention_Array);

      generic
         type Part_Extention is new Part with private;
         type Part_Extention_Array is array (Part_Index range <>) of
           aliased Part_Extention;
         with procedure The_New_Part
           (Node   : Part_Node;
            Result : in out Part_Extention'Class) is null;
      procedure Generic_Copy_Parts
        (Self          : in out Constructor_Node'Class;
         Result        : out Part_Extention_Array);

      procedure New_Part
        (Node   : Part_Node;
         Result : in out Part'Class);

   end Constructor_Nodes;

   type Constructor_Base is
     new Constructor_Nodes.Constructor_Node with null record;

   function Find_Part
     (Self : Constructor_Base'Class;
      Name : S.Universal_String)
     return Constructor_Nodes.Part_Key;

end Gela.Grammars;
