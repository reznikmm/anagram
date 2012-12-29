------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

package body Gela.Grammars is

   -----------------
   -- Declaration --
   -----------------

   function Declaration
     (Self : Attribute)
      return Attribute_Declaration_Index
   is
   begin
      return Self.Declaration;
   end Declaration;

   ------------
   -- Denote --
   ------------

   function Denote (Self : Part) return Terminal_Count is
   begin
      return Self.Denoted_Terminal;
   end Denote;

   ------------
   -- Denote --
   ------------

   function Denote (Self : Part) return Non_Terminal_Count is
   begin
      return Self.Denoted_Non_Terminal;
   end Denote;

   -----------
   -- First --
   -----------

   function First (Self : Non_Terminal) return Production_Index is
   begin
      return Self.First;
   end First;

   -----------
   -- First --
   -----------

   function First (Self : Production) return Part_Index is
   begin
      return Self.First;
   end First;

   -----------
   -- First --
   -----------

   function First (Self : Part) return Production_Index is
   begin
      return Self.First;
   end First;

   --------------------
   -- First_Argument --
   --------------------

   function First_Argument (Self : Rule) return Attribute_Index is
   begin
      return Self.First_Argument;
   end First_Argument;

   ---------------------
   -- First_Attribute --
   ---------------------

   function First_Attribute
     (Self : Terminal)
      return Attribute_Declaration_Index
   is
   begin
      return Self.First_Attribute;
   end First_Attribute;

   ---------------------
   -- First_Attribute --
   ---------------------

   function First_Attribute
     (Self : Non_Terminal)
      return Attribute_Declaration_Index
   is
   begin
      return Self.First_Attribute;
   end First_Attribute;

   ----------------
   -- First_Rule --
   ----------------

   function First_Rule (Self : Production) return Rule_Index is
   begin
      return Self.First_Rule;
   end First_Rule;

   -----------
   -- Image --
   -----------

   function Image (Self : Terminal) return S.Universal_String is
   begin
      return Self.Image;
   end Image;

   -----------
   -- Index --
   -----------

   function Index (Self : Terminal) return Terminal_Index is
   begin
      return Self.Index;
   end Index;

   -----------
   -- Index --
   -----------

   function Index (Self : Non_Terminal) return Non_Terminal_Index is
   begin
      return Self.Index;
   end Index;

   -----------
   -- Index --
   -----------

   function Index (Self : Production) return Production_Index is
   begin
      return Self.Index;
   end Index;

   -----------
   -- Index --
   -----------

   function Index (Self : Part) return Part_Index is
   begin
      return Self.Index;
   end Index;

   -----------
   -- Index --
   -----------

   function Index
     (Self : Attribute_Declaration)
      return Attribute_Declaration_Index
   is
   begin
      return Self.Index;
   end Index;

   -----------
   -- Index --
   -----------

   function Index
     (Self : Attribute)
      return Attribute_Index
   is
   begin
      return Self.Index;
   end Index;

   -----------
   -- Index --
   -----------

   function Index (Self : Rule) return Rule_Index is
   begin
      return Self.Index;
   end Index;

   ------------------
   -- Is_Inherited --
   ------------------

   function Is_Inherited
     (Self : Attribute_Declaration)
      return Boolean
   is
   begin
      return Self.Is_Inherited;
   end Is_Inherited;

   -----------------------
   -- Is_Left_Hand_Side --
   -----------------------

   function Is_Left_Hand_Side (Self : Attribute) return Boolean is
   begin
      return Self.Origin = 0;
   end Is_Left_Hand_Side;

   -------------
   -- Is_List --
   -------------

   function Is_List (Self : Non_Terminal) return Boolean is
   begin
      return Self.Is_List;
   end Is_List;

   -----------------------
   -- Is_List_Reference --
   -----------------------

   function Is_List_Reference (Self : Part) return Boolean is
   begin
      return Self.Is_List;
   end Is_List_Reference;

   -------------------------------
   -- Is_Non_Terminal_Reference --
   -------------------------------

   function Is_Non_Terminal_Reference (Self : Part) return Boolean is
   begin
      return Self.Is_Non_Terminal_Reference;
   end Is_Non_Terminal_Reference;

   ---------------
   -- Is_Option --
   ---------------

   function Is_Option (Self : Part) return Boolean is
   begin
      return Self.Is_Option;
   end Is_Option;

   ---------------------------
   -- Is_Terminal_Reference --
   ---------------------------

   function Is_Terminal_Reference (Self : Part) return Boolean is
   begin
      return Self.Is_Terminal_Reference;
   end Is_Terminal_Reference;

   ----------
   -- Last --
   ----------

   function Last (Self : Non_Terminal) return Production_Count is
   begin
      return Self.Last;
   end Last;

   ----------
   -- Last --
   ----------

   function Last (Self : Production) return Part_Count is
   begin
      return Self.Last;
   end Last;

   ----------
   -- Last --
   ----------

   function Last (Self : Part) return Production_Count is
   begin
      return Self.Last;
   end Last;

   -------------------
   -- Last_Argument --
   -------------------

   function Last_Argument (Self : Rule) return Attribute_Count is
   begin
      return Self.Last_Argument;
   end Last_Argument;

   --------------------
   -- Last_Attribute --
   --------------------

   function Last_Attribute
     (Self : Terminal)
      return Attribute_Declaration_Count
   is
   begin
      return Self.Last_Attribute;
   end Last_Attribute;

   --------------------
   -- Last_Attribute --
   --------------------

   function Last_Attribute
     (Self : Non_Terminal)
      return Attribute_Declaration_Count
   is
   begin
      return Self.Last_Attribute;
   end Last_Attribute;

   ---------------
   -- Last_Rule --
   ---------------

   function Last_Rule (Self : Production) return Rule_Count is
   begin
      return Self.Last_Rule;
   end Last_Rule;

   ----------
   -- Name --
   ----------

   function Name (Self : Non_Terminal) return S.Universal_String is
   begin
      return Self.Name;
   end Name;

   ----------
   -- Name --
   ----------

   function Name (Self : Production) return S.Universal_String is
   begin
      return Self.Name;
   end Name;

   ----------
   -- Name --
   ----------

   function Name (Self : Part) return S.Universal_String is
   begin
      return Self.Name;
   end Name;

   ----------
   -- Name --
   ----------

   function Name
     (Self : Attribute_Declaration)
      return S.Universal_String
   is
   begin
      return Self.Name;
   end Name;

   ------------
   -- Origin --
   ------------

   function Origin (Self : Attribute) return Part_Count is
   begin
      return Self.Origin;
   end Origin;

   ------------
   -- Parent --
   ------------

   function Parent    (Self : Part) return Production_Index is
   begin
      return Self.Parent;
   end Parent;

   ------------
   -- Parent --
   ------------

   function Parent (Self : Production) return Non_Terminal_Count is
   begin
      return Self.Parent;
   end Parent;

   ------------
   -- Parent --
   ------------

   function Parent (Self : Rule) return Production_Index is
   begin
      return Self.Parent;
   end Parent;

   ------------
   -- Result --
   ------------

   function Result (Self : Rule) return Attribute_Index is
   begin
      return Self.Result;
   end Result;

   ----------
   -- Text --
   ----------

   function Text (Self : Rule) return S.Universal_String is
   begin
      return Self.Text;
   end Text;

   ---------------
   -- Type_Name --
   ---------------

   function Type_Name
     (Self : Attribute_Declaration)
      return S.Universal_String
   is
   begin
      return Self.Type_Name;
   end Type_Name;

end Gela.Grammars;
