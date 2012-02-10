------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

package body Gela.Grammars is

   function Find
     (Terminal  : Terminal_Array;
      Image : S.Universal_String)
     return Terminal_Count;

   function Find
     (Non_Terminal : Non_Terminal_Array;
      Name : S.Universal_String)
     return Non_Terminal_Count;

   package body Constructor_Nodes is

      ---------
      -- "<" --
      ---------

      function "<" (Left, Right : Alternative_Key) return Boolean is
      begin
         return Left.Non_Terminal < Right.Non_Terminal or else
           (Left.Non_Terminal = Right.Non_Terminal and
              Left.Extension < Right.Extension);
      end "<";

      ---------
      -- "<" --
      ---------

      function "<" (Left, Right : Production_Key) return Boolean is
      begin
         return Left.Parent < Right.Parent or else
           (Left.Parent = Right.Parent and
              Left.Production_Index < Right.Production_Index);
      end "<";

      ---------
      -- "<" --
      ---------

      function "<" (Left, Right : Part_Key) return Boolean is
      begin
         return Left.Parent < Right.Parent or else
           (Left.Parent = Right.Parent and Left.Part_Index < Right.Part_Index);
      end "<";

      --------------------------------
      -- Generic_Copy_Non_Terminals --
      --------------------------------

      procedure Generic_Copy_Non_Terminals
        (Self   : in out Constructor_Node'Class;
         Result : out Non_Terminal_Extention_Array)
      is
         Index : Non_Terminal_Index := Result'First;

         procedure Each (Cursor : Non_Terminal_Maps.Cursor);

         procedure Each (Cursor : Non_Terminal_Maps.Cursor) is
         begin
            Result (Index).Name := Non_Terminal_Maps.Key (Cursor);
            Result (Index).Index := Index;
            Result (Index).First := 1;
            Result (Index).Last := 0;
            Self.Non_Terminals.Replace_Element
              (Cursor, Result (Index)'Unchecked_Access);
            Index := Index + 1;
         end Each;
      begin
         Self.Non_Terminals.Iterate (Each'Access);
      end Generic_Copy_Non_Terminals;

      ------------------------
      -- Generic_Copy_Parts --
      ------------------------

      procedure Generic_Copy_Parts
        (Self          : in out Constructor_Node'Class;
         Result        : out Part_Extention_Array)
      is
         Index : Part_Index := Result'First;

         procedure Each (Cursor : Part_Maps.Cursor);

         procedure Each (Cursor : Part_Maps.Cursor) is
            Key : constant Constructor_Nodes.Part_Key :=
              Part_Maps.Key (Cursor);
            Node : constant Constructor_Nodes.Part_Node :=
              Part_Maps.Element (Cursor);
            Prod : Production'Class renames
              Self.Prod_Map.Element (Key.Parent.Production_Index).all;
         begin
            if Prod.Last = 0 then
               Prod.First := Index;
            end if;

            Prod.Last := Index;

            Result (Index).Name := Node.Name;
            Result (Index).Index := Index;

            The_New_Part (Node, Result (Index));

            if Result (Index).Is_Terminal_Reference then
               Result (Index).Denoted_Terminal :=
                 Self.Terminals.Element (Node.Denote).Index;
            elsif Result (Index).Is_Non_Terminal_Reference then
               Result (Index).Denoted_Non_Terminal :=
                 Self.Non_Terminals.Element (Node.Denote).Index;
            end if;

            Self.Part_Map.Insert
              (Key.Part_Index, Result (Index)'Unchecked_Access);

            Index := Index + 1;
         end Each;
      begin
         Self.Parts.Iterate (Each'Access);
      end Generic_Copy_Parts;

      ------------------------------
      -- Generic_Copy_Productions --
      ------------------------------

      procedure Generic_Copy_Productions
        (Self          : in out Constructor_Node'Class;
         Result        : out Production_Extention_Array)
      is
         Index : Production_Index := Result'First;

         procedure Each (Cursor : Production_Maps.Cursor);

         procedure Each (Cursor : Production_Maps.Cursor) is
            Key : constant Constructor_Nodes.Production_Key :=
              Production_Maps.Key (Cursor);
            Node : constant Constructor_Nodes.Production_Node :=
              Production_Maps.Element (Cursor);
         begin
            Result (Index).Name := Node.Name;
            Result (Index).Index := Index;
            Result (Index).First := 1;
            Result (Index).Last := 0;

            Self.Prod_Map.Insert
              (Key.Production_Index, Result (Index)'Unchecked_Access);

            if not Key.Parent.Non_Terminal.Is_Empty then
               declare
                  NT : Non_Terminal'Class renames
                    Self.Non_Terminals.Element (Key.Parent.Non_Terminal).all;
               begin
                  if NT.Last = 0 then
                     NT.First := Index;
                  end if;

                  NT.Last := Index;
               end;
            end if;

            Index := Index + 1;
         end Each;
      begin
         Self.Productions.Iterate (Each'Access);
      end Generic_Copy_Productions;

      --------------------
      -- Copy_Terminals --
      --------------------

      procedure Generic_Copy_Terminals
        (Self   : in out Constructor_Node'Class;
         Result : out Terminal_Extention_Array)
      is
         Index : Terminal_Index := Result'First;

         procedure Each (Cursor : Terminal_Maps.Cursor);

         procedure Each (Cursor : Terminal_Maps.Cursor) is
         begin
            Result (Index).Image := Terminal_Maps.Key (Cursor);
            Result (Index).Index := Index;
            Self.Terminals.Replace_Element
              (Cursor, Result (Index)'Unchecked_Access);
            Index := Index + 1;
         end Each;
      begin
         Self.Terminals.Iterate (Each'Access);
      end Generic_Copy_Terminals;

      --------------
      -- New_Part --
      --------------

      procedure New_Part
        (Node   : Part_Node;
         Result : in out Part'Class)
      is
      begin
         if Node.Is_Terminal then
            Result.Is_Terminal_Reference := True;
            Result.Is_Non_Terminal_Reference := False;
            Result.Denoted_Non_Terminal := 0;
         else
            Result.Is_Terminal_Reference := False;
            Result.Is_Non_Terminal_Reference := True;
            Result.Denoted_Terminal := 0;
         end if;
      end New_Part;
   end Constructor_Nodes;

   ------------
   -- Denote --
   ------------

   function Denote (Self : access Part) return Terminal_Count is
   begin
      return Self.Denoted_Terminal;
   end Denote;

   ------------
   -- Denote --
   ------------

   function Denote (Self : access Part) return Non_Terminal_Count is
   begin
      return Self.Denoted_Non_Terminal;
   end Denote;

   ----------
   -- Find --
   ----------

   function Find
     (Non_Terminal : Non_Terminal_Array;
      Name : S.Universal_String)
     return Non_Terminal_Count
   is
      use type S.Universal_String;

      High   : Non_Terminal_Count := Non_Terminal'Last;
      Low    : Non_Terminal_Index := Non_Terminal'First;
      Middle : Non_Terminal_Index;
   begin
      while High >= Low loop
         Middle := (High + Low) / 2;

         if Non_Terminal (Middle).Name = Name then
            return Middle;
         elsif Non_Terminal (Middle).Name < Name then
            Low := Middle + 1;
         else
            High := Middle - 1;
         end if;
      end loop;

      return 0;
   end Find;

   ----------
   -- Find --
   ----------

   function Find
     (Self : Grammar;
      Name : S.Universal_String)
     return Non_Terminal_Count
   is
   begin
      return Find (Self.Non_Terminal, Name);
   end Find;

   ----------
   -- Find --
   ----------

   function Find
     (Terminal  : Terminal_Array;
      Image : S.Universal_String)
     return Terminal_Count
   is
      use type S.Universal_String;

      High   : Terminal_Count := Terminal'Last;
      Low    : Terminal_Index := Terminal'First;
      Middle : Terminal_Index;
   begin
      while High >= Low loop
         Middle := (High + Low) / 2;

         if Terminal (Middle).Image = Image then
            return Middle;
         elsif Terminal (Middle).Image < Image then
            Low := Middle + 1;
         else
            High := Middle - 1;
         end if;
      end loop;

      return 0;
   end Find;

   ----------
   -- Find --
   ----------

   function Find
     (Self  : Grammar;
      Image : S.Universal_String)
     return Terminal_Count is
   begin
      return Find (Self.Terminal, Image);
   end Find;

   ---------------
   -- Find_Part --
   ---------------

   function Find_Part
     (Self : Constructor_Base'Class;
      Name : S.Universal_String)
     return Constructor_Nodes.Part_Key
   is
      use type S.Universal_String;
      use type Constructor_Nodes.Production_Key;
      use Constructor_Nodes.Part_Maps;

      Pos   : Cursor := Self.Parts.First;
   begin
      while Has_Element (Pos) loop
         if Key (Pos).Parent = Self.Last_Production and then
           Element (Pos).Name = Name
         then
            return Key (Pos);
         end if;

         Pos := Next (Pos);
      end loop;

      raise Constraint_Error;
   end Find_Part;

   -----------
   -- First --
   -----------

   function First (Self : access Non_Terminal) return Production_Index is
   begin
      return Self.First;
   end First;

   -----------
   -- First --
   -----------

   function First (Self : access Production) return Part_Index is
   begin
      return Self.First;
   end First;

   -----------
   -- Image --
   -----------

   function Image (Self : access Terminal) return S.Universal_String is
   begin
      return Self.Image;
   end Image;

   -----------
   -- Index --
   -----------

   function Index (Self : access Terminal) return Terminal_Index is
   begin
      return Self.Index;
   end Index;

   -----------
   -- Index --
   -----------

   function Index (Self : access Non_Terminal) return Non_Terminal_Index is
   begin
      return Self.Index;
   end Index;

   -----------
   -- Index --
   -----------

   function Index (Self : access Production) return Production_Index is
   begin
      return Self.Index;
   end Index;

   -----------
   -- Index --
   -----------

   function Index (Self : access Part) return Part_Index is
   begin
      return Self.Index;
   end Index;

   -------------------------------
   -- Is_Non_Terminal_Reference --
   -------------------------------

   function Is_Non_Terminal_Reference (Self : access Part) return Boolean is
   begin
      return Self.Is_Non_Terminal_Reference;
   end Is_Non_Terminal_Reference;

   ---------------------------
   -- Is_Terminal_Reference --
   ---------------------------

   function Is_Terminal_Reference (Self : access Part) return Boolean is
   begin
      return Self.Is_Terminal_Reference;
   end Is_Terminal_Reference;

   ----------
   -- Last --
   ----------

   function Last (Self : access Non_Terminal) return Production_Count is
   begin
      return Self.Last;
   end Last;

   ----------
   -- Last --
   ----------

   function Last (Self : access Production) return Part_Count is
   begin
      return Self.Last;
   end Last;

   ----------
   -- Name --
   ----------

   function Name (Self : access Non_Terminal) return S.Universal_String is
   begin
      return Self.Name;
   end Name;

   ----------
   -- Name --
   ----------

   function Name (Self : access Production) return S.Universal_String is
   begin
      return Self.Name;
   end Name;

   ----------
   -- Name --
   ----------

   function Name (Self : access Part) return S.Universal_String is
   begin
      return Self.Name;
   end Name;

end Gela.Grammars;
