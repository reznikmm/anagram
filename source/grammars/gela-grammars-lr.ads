------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Ada.Unchecked_Deallocation;

package Gela.Grammars.LR is

   --  LR item is place of "parsing point" inside production, like this:
   --  E := A . B C
   --  or
   --  E := . A B C
   --  Kernel LR items are those which point is NOT in the leftmost position,
   --  except dedicated starting production.

   type LR_Item is new Part_Count;
   --  LR_Item represent only kernel items.
   --  Items in form E := A . B C are encoded as (Part_Index (A))
   --  Items in form S' := . S (only for start symbol) are encoded as 0

   function To_Item (X : Part_Index) return LR_Item;
   --  Cast part into LR_Item that point after X.

   type LR_Item_Array is array (LR_Item range <>) of Boolean with Pack;

   type LR_Item_Set (Last_Item : LR_Item) is record
      Items : LR_Item_Array (0 .. Last_Item);
   end record;
   --  Represent set of LR_Items

   function Is_Empty (Set : LR_Item_Set) return Boolean;
   --  Check if given set is empty

   type State_Count is new Natural;
   subtype State_Index is State_Count range 1 .. State_Count'Last;
   --  State_Count and State_Index enumerates state of LR parser

   type LR_Item_Array_Array is array (LR_Item range <>, State_Index range <>)
     of Boolean with Pack;

   type Reference is new Integer;
   --  Represent both terminal or non-terminal symbol.
   --  Encode terminal reference as (-Terminal_Index) and non-termianl as
   --  (Non_Terminal_Index)

   function To_Reference (T  : Terminal_Index) return Reference;
   function To_Reference (NT : Non_Terminal_Index) return Reference;

   type Reference_Array is array (Reference range <>, State_Index range <>)
     of State_Count;

   type Set_Of_LR_Item_Set
     (Length          : State_Index;
      Last_Item       : LR_Item;
      First_Reference : Reference;
      Last_Reference  : Reference)
   is record
      Last  : State_Count;
      Items : LR_Item_Array_Array (0 .. Last_Item, 1 .. Length);
      Go_To :
         Reference_Array (First_Reference .. Last_Reference, 1 .. Length);
      --  References are symbols for which Goto set is not empty
   end record;

   type Set_Of_LR_Item_Set_Access is access all Set_Of_LR_Item_Set;

   procedure Free is new Ada.Unchecked_Deallocation
     (Set_Of_LR_Item_Set, Set_Of_LR_Item_Set_Access);

   procedure To_Set
     (Data   : Set_Of_LR_Item_Set_Access;
      State  : State_Index;
      Result : out LR_Item_Set);
   --  Extract LR_Item set by State index

   procedure Go
     (Input  : Grammar;
      Data   : LR_Item_Set;
      Symbol : Reference;
      Result : out LR_Item_Set);
   --  Find 'goto' set for given item set and terminal/non-terminal Symbol.
   --  This function expects only kernel items in Data and returns only
   --  kernel items in result.

   function Items (Input : Grammar) return Set_Of_LR_Item_Set_Access;
   --  Find set of sets of LR(0) items for given grammar

   function To_Production
     (Input : Grammar;
      Item  : LR_Item) return Production_Index;

end Gela.Grammars.LR;
