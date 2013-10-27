------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with League.Strings;

package Gela.Grammars is
   pragma Preelaborate;
   package S renames League.Strings;

   type Terminal_Count is new Natural;
   type Non_Terminal_Count is new Natural;
   type Production_Count is new Natural;
   type Part_Count is new Natural;
   type Attribute_Declaration_Count is new Natural;
   type Attribute_Count is new Natural;
   type Rule_Count is new Natural;

   subtype Terminal_Index is Terminal_Count range 1 .. Terminal_Count'Last;

   subtype Non_Terminal_Index is Non_Terminal_Count
     range 1 .. Non_Terminal_Count'Last;

   subtype Production_Index is Production_Count
     range 1 .. Production_Count'Last;

   subtype Part_Index is Part_Count range 1 .. Part_Count'Last;

   subtype Attribute_Declaration_Index is Attribute_Declaration_Count
     range 1 .. Attribute_Declaration_Count'Last;

   subtype Attribute_Index is Attribute_Count
     range 1 .. Attribute_Count'Last;

   subtype Rule_Index is Rule_Count range 1 .. Rule_Count'Last;

   type Terminal is tagged private;
   function Image (Self : Terminal) return S.Universal_String;
   function Index (Self : Terminal) return Terminal_Index;

   function First_Attribute
     (Self : Terminal)
     return Attribute_Declaration_Index;

   function Last_Attribute
     (Self : Terminal)
     return Attribute_Declaration_Count;

   type Non_Terminal is tagged private;
   function Is_List (Self : Non_Terminal) return Boolean;
   function Name  (Self : Non_Terminal) return S.Universal_String;
   function Index (Self : Non_Terminal) return Non_Terminal_Index;
   function First (Self : Non_Terminal) return Production_Index;
   function Last  (Self : Non_Terminal) return Production_Count;

   function First_Attribute
     (Self : Non_Terminal)
     return Attribute_Declaration_Index;

   function Last_Attribute
     (Self : Non_Terminal)
     return Attribute_Declaration_Count;

   type Production is tagged private;
   function Name  (Self : Production) return S.Universal_String;
   function Index (Self : Production) return Production_Index;
   function First (Self : Production) return Part_Index;
   function Last  (Self : Production) return Part_Count;
   function First_Rule (Self : Production) return Rule_Index;
   function Last_Rule  (Self : Production) return Rule_Count;
   function Parent (Self : Production) return Non_Terminal_Count;

   type Part is tagged private;
   function Name  (Self : Part) return S.Universal_String;
   function Index (Self : Part) return Part_Index;
   function Is_Terminal_Reference     (Self : Part) return Boolean;
   function Is_Non_Terminal_Reference (Self : Part) return Boolean;
   function Is_List_Reference (Self : Part) return Boolean;
   function Denote (Self : Part) return Terminal_Count;
   --  Only if Is_Terminal_Reference
   function Denote (Self : Part) return Non_Terminal_Count;
   --  Only if Is_Non_Terminal_Reference or Is_List_Reference
   function Is_Option (Self : Part) return Boolean;
   --  Only if Is_Option:
   function First     (Self : Part) return Production_Index;
   function Last      (Self : Part) return Production_Count;
   function Parent    (Self : Part) return Production_Index;

   type Attribute_Declaration is tagged private;

   function Is_Inherited (Self : Attribute_Declaration) return Boolean;

   function Name
     (Self : Attribute_Declaration)
     return S.Universal_String;

   function Type_Name
     (Self : Attribute_Declaration)
     return S.Universal_String;

   function Index
     (Self : Attribute_Declaration)
     return Attribute_Declaration_Index;

   type Attribute is tagged private;

   function Has_Default       (Self : Attribute) return Boolean;
   function Is_Left_Hand_Side (Self : Attribute) return Boolean;
   function Index             (Self : Attribute) return Attribute_Index;
   function Parent            (Self : Attribute) return Rule_Index;
   function Origin            (Self : Attribute) return Part_Count;
   --  Only if not Is_Left_Hand_Side

   function Declaration
     (Self : Attribute)
     return Attribute_Declaration_Index;

   type Rule is tagged private;

   function Index          (Self : Rule) return Rule_Index;
   function Result         (Self : Rule) return Attribute_Index;
   function First_Argument (Self : Rule) return Attribute_Index;
   function Last_Argument  (Self : Rule) return Attribute_Count;
   function Parent         (Self : Rule) return Production_Index;
   function Text           (Self : Rule) return S.Universal_String;

   type Associate_Kind is (Undefined, None, Left, Right);
   type Precedence_Level is new Natural;
   type Precedence_Value (Associative : Associate_Kind := Undefined) is record
      case Associative is
         when Undefined =>
            null;
         when None | Left | Right =>
            Level : Precedence_Level;
      end case;
   end record;

   Undefined_Precedence : constant Precedence_Value :=
     (Associative => Undefined);

   function Precedence (Self : Terminal) return Precedence_Value;
   function Precedence (Self : Production) return Precedence_Value;

   type Terminal_Array is array (Terminal_Index range <>) of aliased Terminal;

   type Non_Terminal_Array is array (Non_Terminal_Index range <>) of
     aliased Non_Terminal;

   type Production_Array is array (Production_Index range <>) of
     aliased Production;

   type Part_Array is array (Part_Index range <>) of aliased Part;

   type Declaration_Array is array (Attribute_Declaration_Index range <>) of
     aliased Attribute_Declaration;

   type Attribute_Array is array (Attribute_Index range <>) of
     aliased Attribute;

   type Rule_Array is array (Rule_Index range <>) of aliased Rule;

   type Grammar
     (Last_Terminal     : Terminal_Count;
      Last_Non_Terminal : Non_Terminal_Count;
      Last_Production   : Production_Count;
      Last_Part         : Part_Count;
      Last_Declaration  : Attribute_Declaration_Count;
      Last_Attribute    : Attribute_Count;
      Last_Rule         : Rule_Count) is
   tagged record
      Root         : Non_Terminal_Index;
      Terminal     : Terminal_Array     (1 .. Last_Terminal);
      Non_Terminal : Non_Terminal_Array (1 .. Last_Non_Terminal);
      Production   : Production_Array   (1 .. Last_Production);
      Part         : Part_Array         (1 .. Last_Part);
      Declaration  : Declaration_Array  (1 .. Last_Declaration);
      Attribute    : Attribute_Array    (1 .. Last_Attribute);
      Rule         : Rule_Array         (1 .. Last_Rule);
      With_List    : S.Universal_String;
   end record;

   type Grammar_Access is access all Grammar;

private

   type Terminal is tagged record
      Image : S.Universal_String;
      Index : Terminal_Index;
      First_Attribute : Attribute_Declaration_Index := 1;
      Last_Attribute  : Attribute_Declaration_Count := 0;
      Precedence      : Precedence_Value;
   end record;

   type Non_Terminal is tagged record
      Name  : S.Universal_String;
      Index : Non_Terminal_Index;
      First : Production_Index;
      Last  : Production_Count;
      Is_List         : Boolean;
      First_Attribute : Attribute_Declaration_Index := 1;
      Last_Attribute  : Attribute_Declaration_Count := 0;
   end record;

   type Production is tagged record
      Name  : S.Universal_String;
      Index : Production_Index;
      First : Part_Index;
      Last  : Part_Count;
      First_Rule : Rule_Index := 1;
      Last_Rule  : Rule_Count := 0;
      Parent     : Non_Terminal_Count;
      Precedence : Precedence_Value;
   end record;

   type Part is tagged record
      Name                      : S.Universal_String;
      Index                     : Part_Index;
      Parent                    : Production_Index;
      Is_Terminal_Reference     : Boolean;
      Is_Non_Terminal_Reference : Boolean;
      Is_List                   : Boolean;
      Is_Option                 : Boolean;
      Denoted_Terminal          : Terminal_Count;
      Denoted_Non_Terminal      : Non_Terminal_Count;
      First : Production_Index;
      Last  : Production_Count;
   end record;

   type Attribute_Declaration is tagged record
      Name         : S.Universal_String;
      Type_Name    : S.Universal_String;
      Index        : Attribute_Declaration_Index;
      Is_Inherited : Boolean;
   end record;

   type Attribute is tagged record
      Index             : Attribute_Index;
      Origin            : Part_Count;
      Parent            : Rule_Index;
      Has_Default       : Boolean;
      Declaration       : Attribute_Declaration_Index;
   end record;

   type Rule is tagged record
      Index          : Rule_Index;
      Result         : Attribute_Count := 0;
      First_Argument : Attribute_Index;
      Last_Argument  : Attribute_Count;
      Parent         : Production_Index;
      Text           : S.Universal_String;
   end record;

end Gela.Grammars;
