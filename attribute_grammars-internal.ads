with Graphs;

package Attribute_Grammars.Internal is

   function Attribute_Count (P : Production) return Natural;

   function Dependency (P : Production) return Graphs.Graph;

   type Graph_List is array (Positive range <>) of Graphs.Graph;

   procedure Find_Cycle
     (AG         : Attribute_Grammar;
      Has_Cycle  : out Boolean;
      Dep_List   : out Graph_List);

end Attribute_Grammars.Internal;
