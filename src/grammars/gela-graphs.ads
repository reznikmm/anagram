------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Interfaces;

package Gela.Graphs is

   type Node_Count is range 0 .. 64;

   subtype Node_Index is Node_Count range 1 .. Node_Count'Last;

   type Graph (Size : Node_Count := Node_Count'Last) is private;
   --  Size - number of nodes in graph

   function Edge (Self : Graph; A, B : Node_Index) return Boolean;
   pragma Inline (Edge);

   procedure Set_Edge
     (Self  : in out Graph;
      A, B  : Node_Index;
      Value : Boolean := True);
   pragma Inline (Set_Edge);

   procedure Add
     (Left  : in out Graph;
      Right : Graph;
      Shift : Node_Count := 0);
   --  For each edge (A, B) in Right add (A+Shift, B+Shift) to Left.
   --  Right.Size + Shift not more then Left.Size.

   procedure Add_Subgraph
     (Left  : in out Graph;
      Right : Graph);
   --  Left.Size <= Right.Size
   --  Add edges (A, B) from Right to Left, if both A and B <= Left.Size

   procedure Add_Subgraph
     (Left    : in out Graph;
      Right   : Graph;
      Changed : in out Boolean;
      Shift   : Node_Count := 0);

   procedure Path_Closure (X : in out Graph);
   --  For each path (A0,A1),(A1,A2) .. (AN-1, AN) add edge (A0,AN) to X

   function Has_Self_Cycles (X : Graph) return Boolean;
   --  Check for each A if X has (A, A) edges.

   function Intersect (X, Y : Graph) return Boolean;
   --  Check if X and Y has any the same edges.

   function Difference_Is_Empty (X, Y : Graph) return Boolean;
   --  X has any edge from Y

private

   type Unsigned is new Interfaces.Unsigned_64;

   type Unsigned_Array is array (Node_Index range <>) of Unsigned;

   type Graph (Size : Node_Count := Node_Count'Last) is record
      X : Unsigned_Array (1 .. Size) := (1 .. Size => 0);
   end record;

end Gela.Graphs;
