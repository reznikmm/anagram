------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with League.Strings;
with League.String_Vectors;
with Ada.Containers.Ordered_Maps;
with Ada.Containers.Vectors;
with Ada.Containers.Doubly_Linked_Lists;
with Anagram.Grammars.Constructors;

package Anagram.Grammars.Parser_Utils is

   type Production_List;
   type Production_List_Access is access all Production_List;

   type Part_Kind is
     (Reference_Kind, List_Reference_Kind, Option_Kind, List_Kind);
   subtype Named_Part_Kind is Part_Kind range Reference_Kind .. Option_Kind;

   type Part (Kind : Part_Kind := List_Kind) is record
      case Kind is
         when Reference_Kind | List_Reference_Kind =>
            Reference : League.Strings.Universal_String;
         when List_Kind | Option_Kind =>
            List : Production_List_Access;
      end case;
   end record;

   type Part_Access is access all Part;
   function "<" (L, R : Part_Access) return Boolean;

   type Named_Part is record
      Name : League.Strings.Universal_String;
      Data : Part_Access;
   end record;

   package Named_Part_Vectors is new
     Ada.Containers.Vectors (Positive, Named_Part);

   type Production is record
      Parts : Named_Part_Vectors.Vector;
   end record;

   type Production_Access is access all Production;

   type Named_Production is record
      Name : League.Strings.Universal_String;
      Data : Production_Access;
   end record;

   package Named_Production_Vectors is new
     Ada.Containers.Vectors (Positive, Named_Production);

   type Production_List is record
      Productions : Named_Production_Vectors.Vector;
   end record;

   type List is record
      Data : Production_List_Access;
   end record;

   type Context_Node is tagged private;

   procedure Error
     (Self  : in out Context_Node;
      Text  : Wide_Wide_String);

   procedure Add_Token
     (Self  : in out Context_Node;
      Image : League.Strings.Universal_String);

   procedure Add_Token
     (Self  : in out Context_Node;
      Image : League.Strings.Universal_String;
      Prio  : League.Strings.Universal_String;
      Assoc : League.Strings.Universal_String);

   procedure Add_With
     (Self  : in out Context_Node;
      Image : League.Strings.Universal_String);

   function Add_Reference
     (Self  : in out Context_Node;
      Text  : League.Strings.Universal_String)
     return Part_Access;

   function Add_List_Reference
     (Self  : in out Context_Node;
      Text  : League.Strings.Universal_String)
     return Part_Access;

   function Add_List
     (Self  : in out Context_Node;
      List  : Production_List_Access)
     return Part_Access;

   function Add_Option
     (Self   : in out Context_Node;
      Option : Production_List_Access)
     return Part_Access;

   function To_Named_Part
     (Self : in out Context_Node;
      Data : Part_Access;
      Name : League.Strings.Universal_String :=
        League.Strings.Empty_Universal_String)
     return Named_Part;

   function New_Production
     (Self : in out Context_Node;
      Item : Named_Part)
      return Production_Access;

   function Add_Part
     (Self : in out Context_Node;
      List : Production_Access;
      Item : Named_Part)
      return Production_Access;

   function To_Named_Production
     (Self : in out Context_Node;
      Data : Production_Access;
      Name : League.Strings.Universal_String :=
        League.Strings.Empty_Universal_String)
     return Named_Production;

   function New_Production_List
     (Self : in out Context_Node;
      Item : Named_Production)
     return Production_List_Access;

   function New_Production_List
     (Self : in out Context_Node;
      Item : Production_Access)
     return Production_List_Access;

   function Add_Production
     (Self : in out Context_Node;
      List : Production_List_Access;
      Item : Named_Production)
     return Production_List_Access;

   procedure Add_Non_Terminal
     (Self  : in out Context_Node;
      Name  : League.Strings.Universal_String;
      List  : Production_List_Access);

   procedure Add_Inherited_Attr
     (Self   : in out Context_Node;
      Target : League.String_Vectors.Universal_String_Vector;
      Names  : League.String_Vectors.Universal_String_Vector;
      Tipe   : League.Strings.Universal_String);

   procedure Add_Synthesized_Attr
     (Self   : in out Context_Node;
      Target : League.String_Vectors.Universal_String_Vector;
      Names  : League.String_Vectors.Universal_String_Vector;
      Tipe   : League.Strings.Universal_String);

   procedure Add_Local_Attr
     (Self   : in out Context_Node;
      Target : League.String_Vectors.Universal_String_Vector;
      Names  : League.String_Vectors.Universal_String_Vector;
      Tipe   : League.Strings.Universal_String);

   procedure Add_Rule
     (Self   : in out Context_Node;
      Target : League.String_Vectors.Universal_String_Vector;
      Text   : League.Strings.Universal_String);

   procedure Add_Priority
     (Self  : in out Context_Node;
      Name  : League.Strings.Universal_String;
      Prio  : League.Strings.Universal_String;
      Assoc : League.Strings.Universal_String);

   procedure Complete
     (Self        : in out Context_Node;
      Constructor : in out Anagram.Grammars.Constructors.Constructor;
      Tail_List   : Boolean := False);

private

   use type League.Strings.Universal_String;

   type Attribute_Declaration is record
      Target : League.String_Vectors.Universal_String_Vector;
      Names  : League.String_Vectors.Universal_String_Vector;
      Tipe   : League.Strings.Universal_String;
   end record;

   package Attribute_Declaration_Lists is
     new Ada.Containers.Doubly_Linked_Lists (Attribute_Declaration);

   function Less (Left, Right : Production_List_Access) return Boolean;

   package List_Part_Maps is new Ada.Containers.Ordered_Maps
     (Production_List_Access, Part_Access, Less);

   package Reference_Part_Maps is new Ada.Containers.Ordered_Maps
     (League.Strings.Universal_String, Part_Access);

   package Non_Terminal_Maps is new Ada.Containers.Ordered_Maps
     (League.Strings.Universal_String, Production_List_Access);

   function Less (Left, Right : Named_Part_Vectors.Vector) return Boolean;

   package Production_Maps is new Ada.Containers.Ordered_Maps
     (Named_Part_Vectors.Vector, Production_Access, Less);

   function Less (L, R : Named_Production_Vectors.Vector) return Boolean;

   package Production_List_Maps is new Ada.Containers.Ordered_Maps
     (Named_Production_Vectors.Vector, Production_List_Access, Less);

   type Rule is record
      Target : League.String_Vectors.Universal_String_Vector;
      Text   : League.Strings.Universal_String;
   end record;

   package Rule_Lists is new Ada.Containers.Doubly_Linked_Lists (Rule);

   package Token_Maps is new Ada.Containers.Ordered_Maps
     (League.Strings.Universal_String, Precedence_Value);

   package List_Maps is new Ada.Containers.Ordered_Maps
     (League.Strings.Universal_String, Production_List_Access);

   type Context_Node is tagged record
      Non_Terminals   : Non_Terminal_Maps.Map;
      Productions     : Production_Maps.Map;
      Prod_Lists      : Production_List_Maps.Map;
      Inherited       : Attribute_Declaration_Lists.List;
      Synthesized     : Attribute_Declaration_Lists.List;
      Local           : Attribute_Declaration_Lists.List;
      List_Parts      : List_Part_Maps.Map;
      Option_Parts    : List_Part_Maps.Map;
      Reference_Parts : Reference_Part_Maps.Map;
      Rules           : Rule_Lists.List;
      Tokens          : Token_Maps.Map;
      Lists           : List_Maps.Map;
      With_List       : League.String_Vectors.Universal_String_Vector;
      Priorities      : Token_Maps.Map;
   end record;

end Anagram.Grammars.Parser_Utils;
