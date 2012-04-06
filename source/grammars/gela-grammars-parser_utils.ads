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

package Gela.Grammars.Parser_Utils is

   type Attribute_Definitions is record
      Names  : League.String_Vectors.Universal_String_Vector;
      Values : League.String_Vectors.Universal_String_Vector;
      Tipe   : League.Strings.Universal_String;
   end record;

   package Attribute_Definitions_Vectors is new
     Ada.Containers.Vectors (Positive, Attribute_Definitions);

   type Production_Index is new Positive;

   package Production_Index_Vectors is new
     Ada.Containers.Vectors (Positive, Production_Index);

   type Part_Kind is (Reference, List, Option);

   type Part_Node (Kind : Part_Kind := List) is record
      Name : League.Strings.Universal_String;

      case Kind is
         when Reference =>
            Reference : League.Strings.Universal_String;
         when List | Option =>
            Nested : Production_Index_Vectors.Vector;
      end case;
   end record;

   package Part_Vectors is new Ada.Containers.Vectors (Positive, Part_Node);

   package Reference_Maps is new Ada.Containers.Ordered_Maps
     (League.Strings.Universal_String,  --  part name
      League.Strings.Universal_String,  --  term or non-term name
      League.Strings."<",
      League.Strings."=");

   procedure Append
     (Left  : in out Reference_Maps.Map;
      Right : Reference_Maps.Map);
   --  No conflict allowed

   procedure Join
     (Left  : in out Reference_Maps.Map;
      Right : Reference_Maps.Map);
   --  If both (Name, Reference) in Left, it's ok

   type Production_Node is record
      Name  : League.Strings.Universal_String;
      Refs  : Reference_Maps.Map;
      Parts : Part_Vectors.Vector;
   end record;

   package Production_Vectors is new Ada.Containers.Vectors
     (Production_Index, Production_Node);

   package NT_Maps is new Ada.Containers.Ordered_Maps
     (League.Strings.Universal_String,
      Production_Index_Vectors.Vector,
      League.Strings."<",
      Production_Index_Vectors."=");

   type Rule_Node is record
      Regexps : League.String_Vectors.Universal_String_Vector;
      Image   : League.Strings.Universal_String;
   end record;

   package Rule_Vectors is new Ada.Containers.Vectors (Positive, Rule_Node);

   type Context_Node is tagged record
      Prod_List   : Production_Vectors.Vector;
      Tokens      : League.String_Vectors.Universal_String_Vector;
      NT          : NT_Maps.Map;
      Start       : League.Strings.Universal_String;
      Inherited   : Attribute_Definitions_Vectors.Vector;
      Synthesized : Attribute_Definitions_Vectors.Vector;
      Rules       : Rule_Vectors.Vector;
   end record;

   procedure Add_NT
     (Self  : in out Context_Node;
      Name  : League.Strings.Universal_String;
      List  : Production_Index_Vectors.Vector);

   procedure Add_Part
     (Self  : in out Context_Node;
      Index : Production_Index;
      Item  : Part_Node);

   procedure Set_Name
     (Self  : in out Context_Node;
      Index : Production_Index;
      Name  : League.Strings.Universal_String);

   procedure New_Production
     (Self   : in out Context_Node;
      Item   : Part_Node;
      Result : out  Production_Index);

end Gela.Grammars.Parser_Utils;
