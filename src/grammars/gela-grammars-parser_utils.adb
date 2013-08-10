------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Ada.Wide_Wide_Text_IO;
with Ada.Unchecked_Deallocation;

package body Gela.Grammars.Parser_Utils is

   function Invent_List_Name
     (Data : Part_Access)
      return League.Strings.Universal_String;

   procedure Free is new Ada.Unchecked_Deallocation (Part, Part_Access);
   procedure Free is new Ada.Unchecked_Deallocation
     (Production, Production_Access);
   procedure Free is new Ada.Unchecked_Deallocation
     (Production_List, Production_List_Access);

   ---------
   -- "<" --
   ---------

   function "<" (L, R : Part_Access) return Boolean is
   begin
      if L.Kind < R.Kind then
         return True;
      elsif L.Kind > R.Kind then
         return False;
      end if;

      case L.Kind is
         when Reference_Kind =>
            return L.Reference < R.Reference;
         when others =>
            return Less (L.List, R.List);
      end case;
   end "<";

   ------------------------
   -- Add_Inherited_Attr --
   ------------------------

   procedure Add_Inherited_Attr
     (Self   : in out Context_Node;
      Target : League.String_Vectors.Universal_String_Vector;
      Names  : League.String_Vectors.Universal_String_Vector;
      Tipe   : League.Strings.Universal_String) is
   begin
      Self.Inherited.Append ((Target, Names, Tipe));
   end Add_Inherited_Attr;

   --------------
   -- Add_List --
   --------------

   function Add_List
     (Self  : in out Context_Node;
      List  : Production_List_Access)
      return Part_Access is
   begin
      if not Self.List_Parts.Contains (List) then
         Self.List_Parts.Insert (List, new Part'(List_Kind, List));
      end if;

      return Self.List_Parts (List);
   end Add_List;

   ------------------------
   -- Add_List_Reference --
   ------------------------

   function Add_List_Reference
     (Self  : in out Context_Node;
      Text  : League.Strings.Universal_String)
      return Part_Access is
   begin
      if not Self.Reference_Parts.Contains (Text) then
         Self.Reference_Parts.Insert
           (Text, new Part'(List_Reference_Kind, Text));
      end if;

      return Self.Reference_Parts (Text);
   end Add_List_Reference;

   ----------------------
   -- Add_Non_Terminal --
   ----------------------

   procedure Add_Non_Terminal
     (Self  : in out Context_Node;
      Name  : League.Strings.Universal_String;
      List  : Production_List_Access) is
   begin
      Self.Non_Terminals.Insert (Name, List);
   end Add_Non_Terminal;

   ----------------
   -- Add_Option --
   ----------------

   function Add_Option
     (Self   : in out Context_Node;
      Option : Production_List_Access)
      return Part_Access
   is
   begin
      if not Self.Option_Parts.Contains (Option) then
         Self.Option_Parts.Insert (Option, new Part'(Option_Kind, Option));
      end if;

      return Self.Option_Parts (Option);
   end Add_Option;

   --------------
   -- Add_Part --
   --------------

   function Add_Part
     (Self : in out Context_Node;
      List : Production_Access;
      Item : Named_Part)
      return Production_Access
   is
      use type Named_Part_Vectors.Vector;

      V : constant Named_Part_Vectors.Vector := List.Parts & Item;
   begin
      if not Self.Productions.Contains (V) then
         Self.Productions.Insert (V, new Production'(Parts => V));
      end if;

      return Self.Productions (V);
   end Add_Part;

   ------------------
   -- Add_Priority --
   ------------------

   procedure Add_Priority
     (Self  : in out Context_Node;
      Name  : League.Strings.Universal_String;
      Prio  : League.Strings.Universal_String;
      Assoc : League.Strings.Universal_String)
   is
      Prec : Precedence_Value
        (Associate_Kind'Wide_Wide_Value (Assoc.To_Wide_Wide_String));
   begin
      if Prec.Associative /= Undefined then
         Prec.Level := Precedence_Level'Value (Prio.To_UTF_8_String);
      end if;

      Self.Priorities.Insert (Name, Prec);
   end Add_Priority;

   --------------------
   -- Add_Production --
   --------------------

   function Add_Production
     (Self : in out Context_Node;
      List : Production_List_Access;
      Item : Named_Production)
      return Production_List_Access
   is
      use type Named_Production_Vectors.Vector;

      V : constant Named_Production_Vectors.Vector := List.Productions & Item;
   begin
      if Item.Name.Is_Empty or V.First_Element.Name.Is_Empty then
         raise Constraint_Error;
      end if;

      if V.Last_Index = 1 and then V.First_Element.Name.Is_Empty then
         raise Constraint_Error;
      end if;

      if not Self.Prod_Lists.Contains (V) then
         Self.Prod_Lists.Insert (V, new Production_List'(Productions => V));
      end if;

      return Self.Prod_Lists (V);
   end Add_Production;

   -------------------
   -- Add_Reference --
   -------------------

   function Add_Reference
     (Self  : in out Context_Node;
      Text  : League.Strings.Universal_String)
      return Part_Access is
   begin
      if not Self.Reference_Parts.Contains (Text) then
         Self.Reference_Parts.Insert (Text, new Part'(Reference_Kind, Text));
      end if;

      return Self.Reference_Parts (Text);
   end Add_Reference;

   --------------
   -- Add_Rule --
   --------------

   procedure Add_Rule
     (Self   : in out Context_Node;
      Target : League.String_Vectors.Universal_String_Vector;
      Text   : League.Strings.Universal_String) is
   begin
      Self.Rules.Append ((Target, Text));
   end Add_Rule;

   --------------------------
   -- Add_Synthesized_Attr --
   --------------------------

   procedure Add_Synthesized_Attr
     (Self   : in out Context_Node;
      Target : League.String_Vectors.Universal_String_Vector;
      Names  : League.String_Vectors.Universal_String_Vector;
      Tipe   : League.Strings.Universal_String) is
   begin
      Self.Synthesized.Append ((Target, Names, Tipe));
   end Add_Synthesized_Attr;

   ---------------
   -- Add_Token --
   ---------------

   procedure Add_Token
     (Self  : in out Context_Node;
      Image : League.Strings.Universal_String) is
   begin
      Self.Tokens.Insert (Image, Undefined_Precedence);
   end Add_Token;

   ---------------
   -- Add_Token --
   ---------------

   procedure Add_Token
     (Self  : in out Context_Node;
      Image : League.Strings.Universal_String;
      Prio  : League.Strings.Universal_String;
      Assoc : League.Strings.Universal_String)
   is
      Prec : Precedence_Value
        (Associate_Kind'Wide_Wide_Value (Assoc.To_Wide_Wide_String));
   begin
      if Prec.Associative /= Undefined then
         Prec.Level := Precedence_Level'Value (Prio.To_UTF_8_String);
      end if;

      Self.Tokens.Insert (Image, Prec);
   end Add_Token;

   --------------
   -- Add_With --
   --------------

   procedure Add_With
     (Self  : in out Context_Node;
      Image : League.Strings.Universal_String) is
   begin
      Self.With_List.Append (Image);
   end Add_With;

   --------------
   -- Complete --
   --------------

   procedure Complete
     (Self        : in out Context_Node;
      Constructor : in out Gela.Grammars.Constructors.Constructor)
   is
      function To_Production_List
        (List   : Production_List_Access;
         Inside : League.Strings.Universal_String :=
           League.Strings.Empty_Universal_String)
        return Gela.Grammars.Constructors.Production_List;

      procedure To_Production
        (Production : Production_Access;
         Result : in out Gela.Grammars.Constructors.Production);

      -------------------
      -- To_Production --
      -------------------

      procedure To_Production
        (Production : Production_Access;
         Result     : in out Gela.Grammars.Constructors.Production) is
      begin
         for Part of Production.Parts loop
            case Part.Data.Kind is
               when Reference_Kind =>
                  if Self.Tokens.Contains (Part.Data.Reference) then
                     Result.Add
                       (Constructor.Create_Terminal_Reference
                          (Part.Name, Part.Data.Reference));
                  else
                     Result.Add
                       (Constructor.Create_Non_Terminal_Reference
                          (Part.Name, Part.Data.Reference));
                  end if;
               when List_Reference_Kind =>
                  Result.Add
                    (Constructor.Create_List_Reference
                       (Part.Name, Part.Data.Reference));
               when others =>
                  declare
                     List : Gela.Grammars.Constructors.Production_List :=
                       To_Production_List (Part.Data.List);
                  begin
                     Result.Add
                       (Constructor.Create_Option (Part.Name, List));
                  end;
            end case;
         end loop;
      end To_Production;

      ------------------------
      -- To_Production_List --
      ------------------------

      function To_Production_List
        (List   : Production_List_Access;
         Inside : League.Strings.Universal_String :=
           League.Strings.Empty_Universal_String)
         return Gela.Grammars.Constructors.Production_List
      is
         Result : Gela.Grammars.Constructors.Production_List :=
           Constructor.Create_Production_List;
      begin
         for Production of List.Productions loop
            declare
               Head : constant League.Strings.Universal_String :=
                 League.Strings.To_Universal_String ("head");
               Item : Gela.Grammars.Constructors.Production :=
                 Constructor.Create_Production (Production.Name);
            begin
               if not Inside.Is_Empty then
                  Item.Add
                    (Constructor.Create_List_Reference
                       (Name => Head,
                        Denote => Inside));
               end if;

               To_Production (Production.Data, Item);
               Result.Add (Item);
            end;
         end loop;

         return Result;
      end To_Production_List;

   begin
      for Token in Self.Tokens.Iterate loop
         Constructor.Create_Terminal
           (Token_Maps.Key (Token),
            Token_Maps.Element (Token));
      end loop;

      for NT in Self.Non_Terminals.Iterate loop
         declare
            List : Gela.Grammars.Constructors.Production_List :=
              To_Production_List (Non_Terminal_Maps.Element (NT));
         begin
            Constructor.Create_Non_Terminal
              (Non_Terminal_Maps.Key (NT),
               List);
         end;
      end loop;

      for NT in Self.Lists.Iterate loop
         declare
            List : Gela.Grammars.Constructors.Production_List :=
              To_Production_List
                (List_Maps.Element (NT), List_Maps.Key (NT));
         begin
            Constructor.Create_List
              (List_Maps.Key (NT),
               List);
         end;
      end loop;

      for Attr of Self.Inherited loop
         for Target in 1 .. Attr.Target.Length loop
            for Name in 1 .. Attr.Names.Length loop
               Constructor.Create_Attribute_Declaration
                 (Non_Terminal => Attr.Target (Target),
                  Name         => Attr.Names (Name),
                  Is_Inherited => True,
                  Type_Name    => Attr.Tipe);
            end loop;
         end loop;
      end loop;

      for Attr of Self.Synthesized loop
         for Target in 1 .. Attr.Target.Length loop
            for Name in 1 .. Attr.Names.Length loop
               if Self.Tokens.Contains (Attr.Target (Target)) then
                  Constructor.Create_Attribute_Declaration
                    (Terminal  => Attr.Target (Target),
                     Name      => Attr.Names (Name),
                     Type_Name => Attr.Tipe);
               else
                  Constructor.Create_Attribute_Declaration
                    (Non_Terminal => Attr.Target (Target),
                     Name         => Attr.Names (Name),
                     Is_Inherited => False,
                     Type_Name    => Attr.Tipe);
               end if;
            end loop;
         end loop;
      end loop;

      for Rule of Self.Rules loop
         for Target in 1 .. Rule.Target.Length loop
            declare
               Items : League.String_Vectors.Universal_String_Vector;
            begin
               Items := Rule.Target (Target).Split ('.');
               Constructor.Create_Rule
                 (Non_Terminal => Items (1),
                  Production   => Items (2),
                  Text         => Rule.Text);
            end;
         end loop;
      end loop;

      for Prio in Self.Priorities.Iterate loop
         declare
            Items : League.String_Vectors.Universal_String_Vector;
         begin
            Items := Token_Maps.Key (Prio).Split ('.');
            Constructor.Set_Precedence
              (Non_Terminal => Items (1),
               Production   => Items (2),
               Precedence   => Token_Maps.Element (Prio));
         end;
      end loop;

      --  Free context
      for Item of Self.List_Parts loop
         Free (Item);
      end loop;

      for Item of Self.Reference_Parts loop
         Free (Item);
      end loop;

      for Item of Self.Option_Parts loop
         Free (Item);
      end loop;

      for Item of Self.Productions loop
         Free (Item);
      end loop;

      for Item of Self.Prod_Lists loop
         Free (Item);
      end loop;

   end Complete;

   -----------
   -- Error --
   -----------

   procedure Error
     (Self  : in out Context_Node;
      Text  : Wide_Wide_String)
   is
      pragma Unreferenced (Self);
   begin
      Ada.Wide_Wide_Text_IO.Put_Line (Text);
   end Error;

   ----------
   -- Less --
   ----------

   function Less (Left, Right : Production_List_Access) return Boolean is
      use type Ada.Containers.Count_Type;
   begin
      if Left.Productions.Length < Right.Productions.Length then
         return True;
      elsif Left.Productions.Length > Right.Productions.Length then
         return False;
      end if;

      for J in 1 .. Left.Productions.Last_Index loop
         if Left.Productions (J).Name = Right.Productions (J).Name then
            if Left.Productions (J).Data /= Right.Productions (J).Data then
               return Less (Left.Productions (J).Data.Parts,
                            Right.Productions (J).Data.Parts);
            end if;
         else
            return Left.Productions (J).Name < Right.Productions (J).Name;
         end if;
      end loop;

      return False;
   end Less;

   ----------
   -- Less --
   ----------

   function Less (Left, Right : Named_Part_Vectors.Vector) return Boolean is
      use type Ada.Containers.Count_Type;
   begin
      if Left.Length < Right.Length then
         return True;
      elsif Left.Length > Right.Length then
         return False;
      end if;

      for J in 1 .. Left.Last_Index loop
         if Left (J).Name = Right (J).Name then
            if Left (J).Data /= Right (J).Data then
               return Left (J).Data < Right (J).Data;
            end if;
         else
            return Left (J).Name < Right (J).Name;
         end if;
      end loop;

      return False;
   end Less;

   ----------
   -- Less --
   ----------

   function Less (L, R : Named_Production_Vectors.Vector) return Boolean is
      use type Ada.Containers.Count_Type;
   begin
      if L.Length < R.Length then
         return True;
      elsif L.Length > R.Length then
         return False;
      end if;

      for J in 1 .. L.Last_Index loop
         if L (J).Name = R (J).Name then
            if L (J).Data /= R (J).Data then
               return Less (L (J).Data.Parts, R (J).Data.Parts);
            end if;
         else
            return L (J).Name < R (J).Name;
         end if;
      end loop;

      return False;
   end Less;

   --------------------
   -- New_Production --
   --------------------

   function New_Production
     (Self : in out Context_Node;
      Item : Named_Part)
      return Production_Access
   is
      use type Named_Part_Vectors.Vector;

      V : constant Named_Part_Vectors.Vector :=
        Named_Part_Vectors.To_Vector (Item, 1);
   begin
      if not Self.Productions.Contains (V) then
         Self.Productions.Insert (V, new Production'(Parts => V));
      end if;

      return Self.Productions (V);
   end New_Production;

   -------------------------
   -- New_Production_List --
   -------------------------

   function New_Production_List
     (Self : in out Context_Node;
      Item : Named_Production)
      return Production_List_Access
   is
      use type Named_Production_Vectors.Vector;

      V : constant Named_Production_Vectors.Vector :=
        Named_Production_Vectors.To_Vector (Item, 1);
   begin
      if not Self.Prod_Lists.Contains (V) then
         Self.Prod_Lists.Insert (V, new Production_List'(Productions => V));
      end if;

      return Self.Prod_Lists (V);
   end New_Production_List;

   -------------------------
   -- New_Production_List --
   -------------------------

   function New_Production_List
     (Self : in out Context_Node;
      Item : Production_Access)
      return Production_List_Access
   is
      use type Named_Production_Vectors.Vector;

      V : constant Named_Production_Vectors.Vector :=
        Named_Production_Vectors.To_Vector
          ((Name => League.Strings.Empty_Universal_String,
            Data => Item), 1);
   begin
      if not Self.Prod_Lists.Contains (V) then
         Self.Prod_Lists.Insert (V, new Production_List'(Productions => V));
      end if;

      return Self.Prod_Lists (V);
   end New_Production_List;

   ----------------------
   -- Invent_List_Name --
   ----------------------

   function Invent_List_Name
     (Data : Part_Access)
      return League.Strings.Universal_String
   is
      Production : Production_Access;
      Part       : Part_Access;
   begin
      if Data.List.Productions.Last_Index = 1 then
         Production := Data.List.Productions.First_Element.Data;

         if Production.Parts.Last_Index = 1 then
            Part := Production.Parts.First_Element.Data;

            if Part.Kind = Reference_Kind then
               return Part.Reference & "_list";
            end if;
         end if;
      end if;

      return League.Strings.Empty_Universal_String;
   end Invent_List_Name;

   -------------------
   -- To_Named_Part --
   -------------------

   function To_Named_Part
     (Self : in out Context_Node;
      Data : Part_Access;
      Name : League.Strings.Universal_String :=
        League.Strings.Empty_Universal_String)
      return Named_Part
   is
   begin
      case Data.Kind is
         when List_Kind =>
            declare
               List_Name : League.Strings.Universal_String := Name;
            begin
               if List_Name.Is_Empty then
                  List_Name := Invent_List_Name (Data);
               end if;

               if List_Name.Is_Empty then
                  raise Constraint_Error;
               elsif not Self.Lists.Contains (List_Name) then
                  Self.Lists.Insert (List_Name, Data.List);
               elsif Self.Lists (List_Name) /= Data.List then
                  raise Constraint_Error;
               end if;

               return (List_Name, Self.Add_List_Reference (List_Name));
            end;
         when Option_Kind =>
            return (Name, Data);
         when Reference_Kind =>
            if Name.Is_Empty then
               return (Data.Reference, Data);
            else
               return (Name, Data);
            end if;
         when List_Reference_Kind =>
            raise Constraint_Error;
      end case;

   end To_Named_Part;

   -------------------------
   -- To_Named_Production --
   -------------------------

   function To_Named_Production
     (Self : in out Context_Node;
      Data : Production_Access;
      Name : League.Strings.Universal_String :=
        League.Strings.Empty_Universal_String)
      return Named_Production
   is
      pragma Unreferenced (Self);
      Text : League.Strings.Universal_String := Name;
   begin
      if Text.Is_Empty then
         if Data.Parts.Last_Index = 1 then
            Text := Data.Parts.First_Element.Name;
         end if;
      end if;

      return (Text, Data);
   end To_Named_Production;

end Gela.Grammars.Parser_Utils;
