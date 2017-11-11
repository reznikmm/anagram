------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Ada.Unchecked_Deallocation;

package Anagram.Grammars.LR is
   pragma Preelaborate;

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

   type LR_Item_Count is new Natural;
   subtype LR_Item_Index is LR_Item_Count range 1 .. LR_Item_Count'Last;

   type LR_Item_Set is array (LR_Item_Index range <>) of LR_Item;
   --  Represent set of LR_Items

   type State_Count is new Natural;
   subtype State_Index is State_Count range 1 .. State_Count'Last;
   --  State_Count and State_Index enumerates state of LR parser

   type Reference is new Integer;
   --  Represent both terminal or non-terminal symbol.
   --  Encode terminal reference as (-Terminal_Index) and non-terminal as
   --  (Non_Terminal_Index)

   function To_Reference (T  : Terminal_Count) return Reference;
   function To_Reference (NT : Non_Terminal_Index) return Reference;
   function To_Reference (P : Part) return Reference;
   pragma Inline (To_Reference);

   type Go_To_Array is array (Reference range <>, State_Index range <>)
     of State_Count;

   type List_Range is record
      First : LR_Item_Index;
      Last  : LR_Item_Index;
   end record;
   --  Boundaries inside LR_Item_Set

   type List_Range_Array is array (State_Index range <>) of List_Range;
   --  Boundaries indexed by state

   type Set_Of_LR_Item_Set
     (Max_States      : State_Index;
      Max_Items       : LR_Item_Index;
      First_Reference : Reference;
      Last_Reference  : Reference)
   is record
      Last_State : State_Count;
      Last_Item  : LR_Item_Count;
      Ranges     : List_Range_Array (1 .. Max_States);
      List       : LR_Item_Set (1 .. Max_Items);
      Go_To      : Go_To_Array
                    (First_Reference .. Last_Reference, 1 .. Max_States);
      --  Go_To - correspoding state for each symbols and state
   end record;

   type Set_Of_LR_Item_Set_Access is access all Set_Of_LR_Item_Set;

   procedure Free is new Ada.Unchecked_Deallocation
     (Set_Of_LR_Item_Set, Set_Of_LR_Item_Set_Access);

   function To_Set
     (Data   : Set_Of_LR_Item_Set_Access;
      State  : State_Index) return LR_Item_Set;
   --  Extract LR_Item set by State index

   function Go
     (Input  : Grammar;
      Data   : LR_Item_Set;
      Symbol : Reference) return LR_Item_Set;
   --  Find 'goto' set for given item set and terminal/non-terminal Symbol.
   --  This function expects only kernel items in Data and returns only
   --  kernel items in result.

   function Items (Input : Grammar) return Set_Of_LR_Item_Set_Access;
   --  Find set of sets of LR(0) items for given grammar

   function To_Production
     (Input : Grammar;
      Item  : LR_Item) return Production_Index;

end Anagram.Grammars.LR;
