------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Gela.Grammars;
with Ada.Containers.Ordered_Maps;

package Gela.Grammars.Ordered is

   type Partition_Count is new Natural;
   subtype Partition_Index is Partition_Count range 1 .. Partition_Count'Last;

   type Partition_Array is array (Attribute_Declaration_Index range <>)
     of Partition_Count;

   type Key is record
      Prod : Production_Index;
      Pass : Positive;
      Step : Positive;
   end record;

   function "<" (Left, Right : Key) return Boolean;

   type Action_Kinds is (Evaluate_Rule, Descent);

   type Action (Kind : Action_Kinds := Action_Kinds'First) is record
      case Kind is
         when Evaluate_Rule =>
            Rule : Rule_Index;
         when Descent =>
            Part : Part_Index;
            Pass : Positive;
      end case;
   end record;

   package Order_Maps is new Ada.Containers.Ordered_Maps (Key, Action);

   procedure Find_Order
     (Input      : Grammar;
      Found      : out Boolean;
      Partitions : out Partition_Array;
      Order      : out Order_Maps.Map);

   function To_Pass
     (Partitions : Partition_Array;
      Attr       : Attribute_Declaration_Index) return Natural;
   --  If Partitions in partition of some NT and Attr is synthesized attribute
   --  of NT, then return pass number where it will be calculated

end Gela.Grammars.Ordered;
