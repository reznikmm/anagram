------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------


package body Gela.Grammars.LR is

   function Find
     (Data : Set_Of_LR_Item_Set_Access;
      Set  : LR_Item_Set)
      return State_Count;

   procedure Append
     (Data : in out Set_Of_LR_Item_Set_Access;
      Set  : LR_Item_Set);

   ------------
   -- Append --
   ------------

   procedure Append
     (Data : in out Set_Of_LR_Item_Set_Access;
      Set  : LR_Item_Set) is
   begin
      if Data.Length = Data.Last then
         declare
            Next : constant Set_Of_LR_Item_Set_Access :=
              new Set_Of_LR_Item_Set'
                (Length          => 2 * Data.Length,
                 Last_Item       => Data.Last_Item,
                 First_Reference => Data.First_Reference,
                 Last_Reference  => Data.Last_Reference,
                 Last            => Data.Last,
                 Items           => (others => (others => False)),
                 Go_To           => (others => (others => 0)));
         begin
            for S in 1 .. Data.Length loop
               for J in Data.Items'Range (1) loop
                  Next.Items (J, S) := Data.Items (J, S);
               end loop;

               for R in Data.Go_To'Range (1) loop
                  Next.Go_To (R, S) := Data.Go_To (R, S);
               end loop;
            end loop;

            Free (Data);
            Data := Next;
         end;
      end if;

      Data.Last := Data.Last + 1;

      for J in Data.Items'Range (1) loop
         Data.Items (J, Data.Last) := Set.Items (J);
      end loop;
   end Append;

   --------------
   -- Contains --
   --------------

   function Find
     (Data : Set_Of_LR_Item_Set_Access;
      Set  : LR_Item_Set)
      return State_Count is
   begin
      for S in 1 .. Data.Last loop
         for J in Set.Items'Range loop
            exit when Data.Items (J, S) /= Set.Items (J);

            if J = Set.Items'Last then
               return S;
            end if;
         end loop;
      end loop;

      return 0;
   end Find;

   --------
   -- Go --
   --------

   procedure Go
     (Input  : Grammar;
      Data   : LR_Item_Set;
      Symbol : Reference;
      Result : out LR_Item_Set)
   is
      function Match (Part : Part_Index) return Boolean;

      procedure Add
        (Part       : Part_Index;
         Production : Production_Index);
      --  Add given Item if matched and check recursive if it's non-terminal
      --  reference. Here Part points to checked part of Production.

      type Non_Terminal_Map is array (Non_Terminal_Index range <>) of Boolean;

      Added : Non_Terminal_Map (1 .. Input.Last_Non_Terminal) :=
        (others => False);


      ---------
      -- Add --
      ---------

      procedure Add
        (Part       : Part_Index;
         Production : Production_Index) is
      begin
         if Part <= Input.Production (Production).Last then
            if Match (Part) then
               Result.Items (To_Item (Part)) := True;
            end if;

            if Input.Part (Part).Is_Non_Terminal_Reference and then
              not Added (Input.Part (Part).Denote)
            then
               declare
                  NT : Grammars.Non_Terminal renames Input.Non_Terminal
                    (Input.Part (Part).Denote);
               begin
                  Added (NT.Index) := True;

                  for P of Input.Production (NT.First .. NT.Last) loop
                     Add (P.First, P.Index);
                  end loop;
               end;
            end if;
         end if;
      end Add;

      -----------
      -- Match --
      -----------

      function Match (Part : Part_Index) return Boolean is
      begin
         if Input.Part (Part).Is_Terminal_Reference then
            return Symbol = To_Reference (T => Input.Part (Part).Denote);
         else
            return Symbol = To_Reference (NT => Input.Part (Part).Denote);
         end if;
      end Match;

      Production : Production_Index;
      Next       : Part_Index;
   begin
      Result.Items := (others => False);

      for Item in Data.Items'Range loop
         if Data.Items (Item) then
            if Item = 0 then  --  X := . A B C
               Production := Input.Non_Terminal (Input.Root).First;
               Next := Input.Production (Production).First;
            else  --  X := A . B C
               Production := To_Production (Input, Item);
               Next := Part_Index (Item + 1);
            end if;

            Add (Next, Production);
         end if;
      end loop;
   end Go;

   --------------
   -- Is_Empty --
   --------------

   function Is_Empty (Set : LR_Item_Set) return Boolean is
   begin
      return Set.Items = (Set.Items'Range => False);
   end Is_Empty;

   -----------
   -- Items --
   -----------

   function Items (Input : Grammar) return Set_Of_LR_Item_Set_Access is
      Index  : State_Index := 1;
      Target : State_Count;
      Result : Set_Of_LR_Item_Set_Access := new Set_Of_LR_Item_Set'
        (Length          => 100,
         Last_Item       => To_Item (Input.Last_Part),
         First_Reference => To_Reference (Input.Last_Terminal),
         Last_Reference  => To_Reference (Input.Last_Non_Terminal),
         Last            => 1,
         Items           => (others => (others => False)),
         Go_To           => (others => (others => 0)));

      Set      : LR_Item_Set (Result.Last_Item);
      Go_Set   : LR_Item_Set (Result.Last_Item);

   begin
      --  S' = .S in State = 1
      Result.Items (0, 1) := True;

      while Index <= Result.Last loop
         To_Set (Result, Index, Set);

         for R in Result.Go_To'Range (1) loop
            Go (Input, Set, R, Go_Set);

            if not Is_Empty (Go_Set) then
               Target := Find (Result, Go_Set);

               if Target = 0 then
                  Append (Result, Go_Set);
                  Target := Result.Last;
               end if;

               Result.Go_To (R, Index) := Target;
            end if;
         end loop;

         Index := Index + 1;
      end loop;

      return Result;
   end Items;

   -------------
   -- To_Item --
   -------------

   function To_Item (X : Part_Index) return LR_Item is
   begin
      return LR_Item (X);
   end To_Item;

   -------------------
   -- To_Production --
   -------------------

   function To_Production
     (Input : Grammar;
      Item  : LR_Item) return Production_Index is
   begin
      if Item = 0 then
         return Input.Non_Terminal (Input.Root).First;
      else
         return Input.Part (Part_Index (Item)).Parent;
      end if;
   end To_Production;

   ------------------
   -- To_Reference --
   ------------------

   function To_Reference (T  : Terminal_Index) return Reference is
   begin
      return Reference (1 - T);
   end To_Reference;

   ------------------
   -- To_Reference --
   ------------------

   function To_Reference (NT : Non_Terminal_Index) return Reference is
   begin
      return Reference (NT);
   end To_Reference;

   ------------
   -- To_Set --
   ------------

   procedure To_Set
     (Data   : Set_Of_LR_Item_Set_Access;
      State  : State_Index;
      Result : out LR_Item_Set)
   is
   begin
      for J in Data.Items'Range (1) loop
         Result.Items (J) := Data.Items (J, State);
      end loop;
   end To_Set;

end Gela.Grammars.LR;
