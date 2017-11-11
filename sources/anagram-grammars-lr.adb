------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

package body Anagram.Grammars.LR is

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
      Set  : LR_Item_Set)
   is
      Last_Item : constant LR_Item_Index := Data.Last_Item + Set'Length;
   begin
      if Data.Max_States = Data.Last_State or Data.Max_Items < Last_Item then
         declare
            Next : constant Set_Of_LR_Item_Set_Access :=
              new Set_Of_LR_Item_Set'
                (Max_States      => (if Data.Max_States = Data.Last_State
                                     then 2 * Data.Max_States
                                     else Data.Max_States),
                 Max_Items       => (if Data.Max_Items < Last_Item
                                     then 2 * Last_Item
                                     else Data.Max_Items),
                 First_Reference => Data.First_Reference,
                 Last_Reference  => Data.Last_Reference,
                 Last_State            => Data.Last_State,
                 Last_Item       => Data.Last_Item,
                 Ranges          => <>,
                 List            => <>,
                 Go_To           => (others => (others => 0)));
         begin
            for S in 1 .. Data.Last_State loop
               for R in Data.Go_To'Range (1) loop
                  Next.Go_To (R, S) := Data.Go_To (R, S);
               end loop;
            end loop;

            Next.Ranges (1 .. Data.Last_State) :=
              Data.Ranges (1 .. Data.Last_State);

            Next.List (1 .. Data.Last_Item) :=
              Data.List (1 .. Data.Last_Item);

            Free (Data);
            Data := Next;
         end;
      end if;

      Data.Last_State := Data.Last_State + 1;

      Data.Ranges (Data.Last_State) :=
        (First => Data.Last_Item + 1,
         Last  => Last_Item);

      Data.Last_Item := Last_Item;

      Data.List (Data.Ranges (Data.Last_State).First
                 .. Data.Ranges (Data.Last_State).Last) := Set;

   end Append;

   ----------
   -- Find --
   ----------

   function Find
     (Data : Set_Of_LR_Item_Set_Access;
      Set  : LR_Item_Set)
      return State_Count is
   begin
      for S in 1 .. Data.Last_State loop
         if Data.List (Data.Ranges (S).First .. Data.Ranges (S).Last)
           = Set
         then
            return S;
         end if;
      end loop;

      return 0;
   end Find;

   --------
   -- Go --
   --------

   function Go
     (Input  : Grammar;
      Data   : LR_Item_Set;
      Symbol : Reference) return LR_Item_Set
   is
      function Match (Part : Part_Index) return Boolean;

      procedure Add
        (Part       : Part_Index;
         Production : Production_Index);
      --  Add given Item if matched and check recursive if it's non-terminal
      --  reference. Here Part points to checked part of Production.

      procedure Append (Part : Part_Index);
      --  Append Part to result set

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
               Append (Part);
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

      Result : LR_Item_Set (1 .. LR_Item_Index (Input.Last_Part));
      Last   : LR_Item_Count := 0;

      ------------
      -- Append --
      ------------

      procedure Append (Part : Part_Index) is
         Item : constant LR_Item := To_Item (Part);
      begin
         for J in 1 .. Last loop
            if Result (J) = Item then
               return;
            elsif Result (J) > Item then
               Result (J + 1 .. Last + 1) := Result (J .. Last);
               Result (J) := Item;
               Last := Last + 1;
               return;
            end if;
         end loop;

         Last := Last + 1;
         Result (Last) := Item;
      end Append;

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
      for Item of Data loop
         if Item = 0 then  --  X := . A B C
            Production := Input.Non_Terminal (Input.Root).First;
            Next := Input.Production (Production).First;
         else  --  X := A . B C
            Production := To_Production (Input, Item);
            Next := Part_Index (Item + 1);
         end if;

         Add (Next, Production);
      end loop;

      return Result (1 .. Last);
   end Go;

   -----------
   -- Items --
   -----------

   function Items (Input : Grammar) return Set_Of_LR_Item_Set_Access is
      Index  : State_Index := 1;
      Target : State_Count;
      Result : Set_Of_LR_Item_Set_Access := new Set_Of_LR_Item_Set'
        (Max_States          => 100,
         Max_Items     => 200,
         First_Reference => To_Reference (Input.Last_Terminal),
         Last_Reference  => To_Reference (Input.Last_Non_Terminal),
         Last_State            => 1,
         Last_Item       => 1,
         Go_To           => (others => (others => 0)),
         Ranges          => (others => <>),
         List            => (others => <>));

   begin
      --  S' = .S in State = 1
      Result.Ranges (1) := (1, 1);
      Result.List (1) := 0;

      while Index <= Result.Last_State loop
         declare
            Set : constant LR_Item_Set := To_Set (Result, Index);
         begin
            for R in Result.Go_To'Range (1) loop
               declare
                  Go_Set : constant LR_Item_Set := Go (Input, Set, R);
               begin
                  if Go_Set'Length > 0 then
                     Target := Find (Result, Go_Set);

                     if Target = 0 then
                        Append (Result, Go_Set);
                        Target := Result.Last_State;
                     end if;

                     Result.Go_To (R, Index) := Target;
                  end if;
               end;
            end loop;
         end;

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

   function To_Reference (T  : Terminal_Count) return Reference is
   begin
      return -Reference (T);
   end To_Reference;

   ------------------
   -- To_Reference --
   ------------------

   function To_Reference (NT : Non_Terminal_Index) return Reference is
   begin
      return Reference (NT);
   end To_Reference;

   ------------------
   -- To_Reference --
   ------------------

   function To_Reference (P : Part) return Reference is
   begin
      if P.Is_Terminal_Reference then
         return To_Reference (T => P.Denote);
      else
         return To_Reference (NT => P.Denote);
      end if;
   end To_Reference;

   ------------
   -- To_Set --
   ------------

   function To_Set
     (Data   : Set_Of_LR_Item_Set_Access;
      State  : State_Index) return LR_Item_Set is
   begin
      return Data.List (Data.Ranges (State).First .. Data.Ranges (State).Last);
   end To_Set;

end Anagram.Grammars.LR;
