------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Ada.Containers.Vectors;

with Gela.Grammars.LR;

package Gela.Grammars.LR_Tables is
   pragma Preelaborate;

   type Table (<>) is tagged private;
   type Table_Access is access all Table;

   procedure Free (Self : in out Table_Access);

   type Reduce_Iterator is private;

   function Is_Empty (Self : Reduce_Iterator) return Boolean;

   function Production (Self : Reduce_Iterator) return Production_Index;

   function Part (Self : Reduce_Iterator) return Part_Count;
   --  This is used only for Right Nulled Tables.
   --  Point to last (right) part included in reduction.

   procedure Next
     (Self : Table;
      Item : in out Reduce_Iterator);

   function Create
     (Last_State        : LR.State_Index;
      Last_Terminal     : Terminal_Index;
      Last_Non_Terminal : Non_Terminal_Index) return Table_Access;

   function Last_State (Self : Table) return LR.State_Index;

   function Shift
     (Self  : Table;
      State : LR.State_Index;
      NT    : Non_Terminal_Index) return LR.State_Count;

   End_Of_File : constant Terminal_Count := 0;

   function Shift
     (Self  : Table;
      State : LR.State_Index;
      T     : Terminal_Count) return LR.State_Count;

   function Reduce
     (Self  : Table;
      State : LR.State_Index;
      T     : Terminal_Count) return Reduce_Iterator;

   function Finish
     (Self  : Table;
      State : LR.State_Index)
      return Boolean;

   procedure Set_Shift
     (Self  : in out Table;
      State : LR.State_Index;
      NT    : Non_Terminal_Index;
      Value : LR.State_Index);

   procedure Set_Shift
     (Self  : in out Table;
      State : LR.State_Index;
      T     : Terminal_Count;
      Value : LR.State_Index);

   procedure Set_Reduce
     (Self  : in out Table;
      State : LR.State_Index;
      T     : Terminal_Count;
      Value : Production_Index;
      Part  : Part_Count := 0);

   procedure Set_Finish
     (Self  : in out Table;
      State : LR.State_Index);

   procedure Remove_Shift
     (Self  : in out Table;
      State : LR.State_Index;
      T     : Terminal_Count);

   procedure Remove_Reduce
     (Self  : in out Table;
      State : LR.State_Index;
      T     : Terminal_Count;
      Value : Production_Index);

   --  Extension of Table to support incremental parsing

   procedure Set_Reduce
     (Self  : in out Table;
      State : LR.State_Index;
      NT    : Non_Terminal_Index;
      Value : Production_Index;
      Part  : Part_Count := 0);

   function Reduce
     (Self  : Table;
      State : LR.State_Index;
      NT    : Non_Terminal_Index) return Reduce_Iterator;

private

   type Reduce_Iterator is record
      Production : Production_Count;
      Part       : Part_Count;
      Next       : Natural;
   end record;

   package Reduce_Iterator_Vectors is
     new Ada.Containers.Vectors (Positive, Reduce_Iterator);

   type Terminal_State_Array is array
     (LR.State_Index range <>,
      Terminal_Count range <>) of LR.State_Count;

   type Boolean_Array is array (LR.State_Index range <>) of Boolean;

   type Terminal_Natural_Array is array
     (LR.State_Index range <>,
      Terminal_Count range <>) of Natural;

   type Non_Terminal_Natural_Array is array
     (LR.State_Index range <>,
      Non_Terminal_Index range <>) of Natural;

   type Non_Terminal_State_Array is array
     (LR.State_Index range <>,
      Non_Terminal_Index range <>) of LR.State_Count;

   type Table (Last_State        : LR.State_Index;
               Last_Terminal     : Terminal_Index;
               Last_Non_Terminal : Non_Terminal_Index) is
   tagged record
      Reduce_Vector : Reduce_Iterator_Vectors.Vector;
      T_Finish      : Boolean_Array (1 .. Last_State);
      T_Shift  : Terminal_State_Array
        (1 .. Last_State, End_Of_File .. Last_Terminal);
      T_Reduce : Terminal_Natural_Array
        (1 .. Last_State, End_Of_File .. Last_Terminal);
      NT_Shift : Non_Terminal_State_Array
        (1 .. Last_State, 1 .. Last_Non_Terminal);
      NT_Reduce : Non_Terminal_Natural_Array
        (1 .. Last_State, 1 .. Last_Non_Terminal);
   end record;

end Gela.Grammars.LR_Tables;
