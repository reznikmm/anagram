------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

private with Ada.Containers.Vectors;
private with Ada.Containers.Ordered_Maps;

package Gela.Grammars.Constructors is

   type Constructor is tagged private;

   type Part is tagged private;

   type Production is tagged private;

   type Production_List is tagged private;

   procedure Create_Terminal
     (Self  : in out Constructor;
      Image : S.Universal_String;
      Prec  : Precedence_Value := Undefined_Precedence);

   procedure Create_Non_Terminal
     (Self : in out Constructor;
      Name : S.Universal_String;
      List : in out Production_List'Class);

   procedure Create_List
     (Self : in out Constructor;
      Name : S.Universal_String;
      List : in out Production_List'Class);

   procedure Create_Attribute_Declaration
     (Self         : in out Constructor;
      Terminal     : S.Universal_String;
      Name         : S.Universal_String;
      Type_Name    : S.Universal_String);

   procedure Create_Attribute_Declaration
     (Self         : in out Constructor;
      Non_Terminal : S.Universal_String;
      Name         : S.Universal_String;
      Is_Inherited : Boolean;
      Type_Name    : S.Universal_String);

   function Create_Terminal_Reference
     (Self  : Constructor'Class;
      Name  : S.Universal_String;
      Image : S.Universal_String)
      return Part;

   function Create_Non_Terminal_Reference
     (Self   : Constructor'Class;
      Name   : S.Universal_String;
      Denote : S.Universal_String)
      return Part;

   function Create_List_Reference
     (Self   : Constructor'Class;
      Name   : S.Universal_String;
      Denote : S.Universal_String)
      return Part;

   function Create_Option
     (Self  : Constructor'Class;
      Name  : S.Universal_String;
      List  : in out Production_List'Class)
      return Part;

   function Create_Production
     (Self   : Constructor'Class;
      Name   : S.Universal_String;
      Prec  : Precedence_Value := Undefined_Precedence)
      return Production;

   function Create_Production_List
     (Self : Constructor'Class)
      return Production_List;

   procedure Add
     (Self : in out Production;
      Item : Part'Class);

   procedure Add
     (List : in out Production_List;
      Item : Production'Class);

   procedure Create_Rule
     (Self         : in out Constructor;
      Non_Terminal : S.Universal_String;
      Production   : S.Universal_String;
      Text         : S.Universal_String);

   procedure Set_Precedence
     (Self         : in out Constructor;
      Non_Terminal : S.Universal_String;
      Production   : S.Universal_String;
      Precedence   : Precedence_Value);

   function Complete (Self : in out Constructor) return Grammar;
   --  Complete construction and return resulting grammar

   function To_Augmented (Input : Grammar) return Grammar;
   --  Return augmented grammar for given one, t.e. add new starting
   --  non-terminal S' and new production S'->S

private

   type Part_Node;
   type Production_Node;
   type Production_List_Node;

   type Part_Access            is access all Part_Node;
   type Production_Access      is access all Production_Node;
   type Production_List_Access is access all Production_List_Node;

   type Part is tagged record
      Data : Part_Access;
   end record;

   type Production is tagged record
      Data : Production_Access;
   end record;

   type Production_List is tagged record
      Data : Production_List_Access;
   end record;

   package Reference_Maps is new Ada.Containers.Ordered_Maps
     (S.Universal_String, Part_Access, S."<");

   type Part_Kinds is
     (Terminal_Reference, Non_Terminal_Reference, List, Option);

   type Part_Node (Kind : Part_Kinds := List) is record
      Index : Part_Index;
      Name  : S.Universal_String;
      case Kind is
         when Terminal_Reference =>
            Image : S.Universal_String;
         when Non_Terminal_Reference | List =>
            Denote : S.Universal_String;
         when Option =>
            List : Production_List_Access;
            Refs : Reference_Maps.Map;
      end case;
   end record;

   package Part_Vectors is
     new Ada.Containers.Vectors (Part_Index, Part_Access);

   type Rule_Data is record
      Text         : S.Universal_String;
      Non_Terminal : S.Universal_String;
      Production   : Production_Access;
   end record;

   package Rule_Vectors is new Ada.Containers.Vectors (Rule_Index, Rule_Data);

   type Production_Node is record
      Index       : Production_Index;
      Name        : S.Universal_String;
      Parts       : Part_Vectors.Vector;
      Rules       : Rule_Vectors.Vector;
      References  : Reference_Maps.Map;
      Attr_Count  : Attribute_Count := 0;
      Prods_Count : Production_Count := 0;
      Parts_Count : Part_Count := 0;
      Precedence  : Precedence_Value;
   end record;

   function Equal_Name (Left, Right : Production_Access) return Boolean;

   package Production_Vectors is
     new Ada.Containers.Vectors
       (Production_Index, Production_Access, Equal_Name);

   type Production_List_Node is record
      Productions : Production_Vectors.Vector;
      Attr_Count  : Attribute_Count := 0;
      Prods_Count : Production_Count := 0;
      Parts_Count : Part_Count := 0;
   end record;

   type Attribute_Declaration is record
      Index        : Attribute_Declaration_Index;
      Name         : S.Universal_String;
      Is_Inherited : Boolean;
      Type_Name    : S.Universal_String;
   end record;

   package Attribute_Declaration_Maps is new Ada.Containers.Ordered_Maps
     (S.Universal_String, Attribute_Declaration, S."<");

   type Terminal is record
      Index : Terminal_Index;
      Name  : S.Universal_String;
      Attr  : Attribute_Declaration_Maps.Map;
      Prec  : Precedence_Value;
   end record;

   package Terminal_Maps is new Ada.Containers.Ordered_Maps
     (S.Universal_String, Terminal, S."<");

   type Non_Terminal is record
      Index   : Non_Terminal_Index;
      Name    : S.Universal_String;
      Attr    : Attribute_Declaration_Maps.Map;
      Is_List : Boolean;
      List    : Production_List_Access;
   end record;

   package Non_Terminal_Maps is new Ada.Containers.Ordered_Maps
     (S.Universal_String, Non_Terminal, S."<");

   type Constructor is tagged record
      Terminals         : Terminal_Maps.Map;
      Non_Terminals     : Non_Terminal_Maps.Map;
      Last_Production   : Production_Count := 0;
      Last_Part         : Part_Count := 0;
      Last_Declaration  : Attribute_Declaration_Count := 0;
      Last_Attribute    : Attribute_Count := 0;
      Last_Rule         : Rule_Count := 0;
   end record;

end Gela.Grammars.Constructors;
