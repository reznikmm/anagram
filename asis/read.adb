with Ada.Strings.Unbounded;
with Ada.Containers.Ordered_Maps;

with Text_Streams.File;
with XML_IO.Stream_Readers;

with Ada.Text_IO;

with Attribute_Grammars.Construction;
with Attribute_Grammars.Print_XML;

with Kind_To_Function;

procedure Read is
   use XML_IO;
   use Ada.Strings.Unbounded;
   package R renames XML_IO.Stream_Readers;

   function "+" (Text : String) return Unbounded_String renames
     To_Unbounded_String;

   type Modifier_Kind is (Required,
                          Single_Item_List,
                          Optional,
                          Optional_List,
                          Not_Empty_List);

   subtype Special_Kind is Modifier_Kind range Optional .. Not_Empty_List;

   type Special_Kind_Flags is array (Special_Kind) of Boolean;
   type Special_Kind_NT is array (Special_Kind) of
     Attribute_Grammars.Nonterminal;

   Empty_Flag : constant Special_Kind_Flags := (others => False);

   type Child is record
      Name     : Unbounded_String;
      Get      : Unbounded_String;
      Modifier : Modifier_Kind;
   end record;

   type Child_Array is array (1 .. 10) of Child;

   type Rule is record
      Name     : Unbounded_String;
      Kind     : Unbounded_String;
      Sub_Kind : Unbounded_String;
      Childs   : Child_Array;
      Length   : Natural := 0;
   end record;

   type Unbounded_String_Array is array (1 .. 20) of Unbounded_String;

   type Alt_Rule is record
      Name     : Unbounded_String;
      Items    : Unbounded_String_Array;
      Length   : Natural := 0;
   end record;

   package Rule_Maps is new Ada.Containers.Ordered_Maps
     (Unbounded_String, Rule);

   package Alt_Rule_Maps is new Ada.Containers.Ordered_Maps
     (Unbounded_String, Alt_Rule);

   use type Attribute_Grammars.Nonterminal;

   type NT_Info is record
      NT       : Attribute_Grammars.Nonterminal;
      Flag     : Special_Kind_Flags;
      Other_NT : Special_Kind_NT;
   end record;

   package NT_Maps is new Ada.Containers.Ordered_Maps
     (Unbounded_String, NT_Info);

   package Enum is
      type Element_Kinds is (AST, Alt_Rule, Alternative, Rule, Child);
   end Enum;

   Rule_Map   : Rule_Maps.Map;
   Alt_Map    : Alt_Rule_Maps.Map;
   References : NT_Maps.Map;

   procedure Read_XML is
      Last_Rule : Rule;
      Last_Alt  : Alt_Rule;

      procedure Append_Reference (Item : Child) is
         Flag : Special_Kind_Flags := Empty_Flag;
         C    : NT_Maps.Cursor := References.Find (Item.Name);
      begin
         if Item.Modifier in Special_Kind then
            Flag (Item.Modifier) := True;
         end if;

         if not NT_Maps.Has_Element (C) then
            References.Insert
              (Item.Name, (Flag => Flag, others => <>));
         elsif Flag /= NT_Maps.Element (C).Flag then
            References.Replace_Element
              (C, (Flag => NT_Maps.Element (C).Flag or Flag, others => <>));
         end if;
      end Append_Reference;

      Stream   : aliased Text_Streams.File.File_Text_Stream;
      Parser   : R.Reader (Stream'Access, R.Default_Buffer_Size);
   begin
      Text_Streams.File.Open (Stream, "asis_ast.xml");
      R.Initialize (Parser);

      while R.More_Pieces (Parser) loop
         case R.Piece_Kind (Parser) is

            when Start_Element =>
               case Enum.Element_Kinds'Value (R.Name (Parser)) is

                  when Enum.Rule =>
                     Last_Rule.Name := +R.Attribute_Value
                       (Parser, "name", Raise_Error => True);
                     Last_Rule.Kind := +R.Attribute_Value
                       (Parser, "kind", Raise_Error => True);
                     Last_Rule.Sub_Kind := +R.Attribute_Value (Parser, "kind");
                     Last_Rule.Length := 0;

                  when Enum.Child =>
                     declare
                        Item : Child renames
                          Last_Rule.Childs (Last_Rule.Length + 1);
                     begin
                        Item.Name := +R.Attribute_Value
                          (Parser, "name", Raise_Error => True);
                        Item.Get := +R.Attribute_Value
                          (Parser, "get", Raise_Error => True);

                        if R.Attribute_Value (Parser, "opt") = "y" then
                           Item.Modifier := Optional;
                        elsif R.Attribute_Value (Parser, "list") = "y" then
                           Item.Modifier := Not_Empty_List;
                        elsif R.Attribute_Value (Parser, "list") = "1" then
                           Item.Modifier := Single_Item_List;
                        elsif R.Attribute_Value (Parser, "list") = "opt" then
                           Item.Modifier := Optional_List;
                        else
                           Item.Modifier := Required;
                        end if;

                        Append_Reference (Item);

                        Last_Rule.Length := Last_Rule.Length + 1;
                     end;

                  when Enum.Alt_Rule =>
                     Last_Alt.Name := +R.Attribute_Value
                       (Parser, "name", Raise_Error => True);
                     Last_Alt.Length := 0;

                  when Enum.Alternative =>
                     declare
                        Item : Unbounded_String renames
                          Last_Alt.Items (Last_Alt.Length + 1);
                     begin
                        Item := +R.Attribute_Value
                          (Parser, "name", Raise_Error => True);

                        Last_Alt.Length := Last_Alt.Length + 1;
                     end;

                  when Enum.AST =>
                     null;
               end case;

            when End_Element =>
               case Enum.Element_Kinds'Value (R.Name (Parser)) is
                  when Enum.Rule =>
                     Rule_Map.Insert (Last_Rule.Name, Last_Rule);

                  when Enum.Alt_Rule =>
                     Alt_Map.Insert (Last_Alt.Name, Last_Alt);

                  when others =>
                     null;
               end case;

            when others =>
               null;
         end case;

         R.Next (Parser);
      end loop;
   end Read_XML;

   AG : Attribute_Grammars.Attribute_Grammar :=
     Attribute_Grammars.Construction.Create;

   procedure NT_Kind
     (Name : Unbounded_String;
      NT   : Attribute_Grammars.Nonterminal;
      Kind : out Unbounded_String)
   is
      use Attribute_Grammars;
      use Attribute_Grammars.Construction;

      Result   : Unbounded_String;
      Found    : Boolean := False;
      Conflict : Boolean := False;

      procedure Add_Production (The_Rule : Rule) is
         Func : constant String :=
           Kind_To_Function.Get (To_String (The_Rule.Kind));
         P : Production;
         X : Part;
      begin
         if not Found then
            Result := To_Unbounded_String (Func);
            Found := True;
         elsif not Conflict and Result /= Func then
            Conflict :=True;
         end if;
      end Add_Production;

      procedure Add (Name : Unbounded_String) is
         Alt : Alt_Rule;
      begin
         if Alt_Map.Contains (Name) then
            Alt := Alt_Map.Element (Name);

            for J in 1 .. Alt.Length loop
               Add (Alt.Items (J));
            end loop;
         else
            Add_Production (Rule_Map.Element (Name));
         end if;
      end Add;
   begin
      Add (Name);

      if Found and not Conflict then
         Kind := Result;
      end if;
   end NT_Kind;

   procedure Construct
     (Name : Unbounded_String;
      NT : Attribute_Grammars.Nonterminal)
   is
      use Attribute_Grammars;
      use Attribute_Grammars.Construction;

      Kind : Unbounded_String;

      procedure Add_Production (The_Rule : Rule) is
         function Get (C : Child) return String is
         begin
            if C.Modifier = Single_Item_List then
               return To_String (C.Get)  & " (X) (1)";
            else
               return To_String (C.Get)  & " (X)";
            end if;
         end Get;

         P : Production;
         X : Part;
      begin
         if Kind = "" then
            declare
               Func : constant String :=
                 Kind_To_Function.Get (To_String (The_Rule.Kind));
               Text : constant String :=
                 Func & " (X) = " & To_String (The_Rule.Kind);
            begin
               Create (NT, Text, P);
            end;
         else
            Create (NT, To_String (The_Rule.Kind), P);
         end if;

         for J in 1 .. The_Rule.Length loop
            Create (P, Get (The_Rule.Childs (J)), X);

            if The_Rule.Childs (J).Modifier in Special_Kind then
               Set_Reference
                 (X, References.Element (The_Rule.Childs (J).Name).Other_NT
                                              (The_Rule.Childs (J).Modifier));
            else
               Set_Reference
                 (X, References.Element (The_Rule.Childs (J).Name).NT);
            end if;
         end loop;
      end Add_Production;

      procedure Add (Name : Unbounded_String) is
         Alt : Alt_Rule;
      begin
         if Alt_Map.Contains (Name) then
            Alt := Alt_Map.Element (Name);

            for J in 1 .. Alt.Length loop
               Add (Alt.Items (J));
            end loop;
         else
            Add_Production (Rule_Map.Element (Name));
         end if;
      end Add;
   begin
      NT_Kind (Name, NT, Kind);

      if Kind /= "" then
         Set_Expression (NT, To_String (Kind) & " (X)");
      end if;

      Add (Name);
   end Construct;

   procedure Construct_List
     (Name : Unbounded_String;
      Item : NT_Info;
      Kind : Special_Kind)
   is
      use Attribute_Grammars;
      use Attribute_Grammars.Construction;

      P : Production;
      X : Part;
   begin
      if Kind = Not_Empty_List then
         Create (Item.Other_NT (Kind), "X'Length = 1", P);
         Create (P, "X (X'First)", X);
         Set_Reference (X, Item.NT);
      else
         Create (Item.Other_NT (Kind), "X'Length = 0", P);
      end if;

      Create (Item.Other_NT (Kind), "", P);

      Create (P, "X (X'First)", X);
      Set_Reference (X, Item.Other_NT (Kind));

      Create (P, "X (X'First + 1 .. X'Last)", X);
      Set_Reference (X, Item.NT);
   end Construct_List;

   procedure Construct_Option
     (Name : Unbounded_String;
      Item : NT_Info)
   is
      use Attribute_Grammars;
      use Attribute_Grammars.Construction;

      P : Production;
      X : Part;
   begin
      Create (Item.Other_NT (Optional), "Is_Nil (X)", P);

      Create (Item.Other_NT (Optional), "", P);

      Create (P, "X", X);
      Set_Reference (X, Item.NT);
   end Construct_Option;

   procedure Construct (C : NT_Maps.Cursor) is
      Item : NT_Info := NT_Maps.Element (C);
   begin
      Construct (NT_Maps.Key (C), Item.NT);

      if Item.Flag (Not_Empty_List) then
         Construct_List (NT_Maps.Key (C), Item, Not_Empty_List);
      end if;

      if Item.Flag (Optional_List) then
         Construct_List (NT_Maps.Key (C), Item, Optional_List);
      end if;

      if Item.Flag (Optional) then
         Construct_Option (NT_Maps.Key (C), Item);
      end if;
   end Construct;

   procedure Create_NT (C : NT_Maps.Cursor) is
      function Suffix (X : Special_Kind) return String is
      begin
         case X is
            when Optional =>
               return "_opt";
            when Optional_List =>
               return "_opt_list";
            when Not_Empty_List =>
               return "_list";
         end case;
      end Suffix;

      function Get_Type (List : Boolean) return String is
      begin
         if NT_Maps.Key (C) = "compilation_unit" then
            return "X : Asis.Compilation_Unit";
         elsif List then
            return "X : Asis.Element_List";
         else
            return "X : Asis.Element";
         end if;
      end Get_Type;

      Item : NT_Info := NT_Maps.Element (C);
      NT : Attribute_Grammars.Nonterminal;
   begin
      Attribute_Grammars.Construction.Create
        (Object     => AG,
         Name       => To_String (NT_Maps.Key (C)),
         Type_Name  => Get_Type (List => False),
         Expression => "",
         Result     => Item.NT);

      for J in Item.Flag'Range loop
         if Item.Flag (J) then
            Attribute_Grammars.Construction.Create
              (Object     => AG,
               Name       => To_String (NT_Maps.Key (C) & Suffix (J)),
               Type_Name  => Get_Type (List => J /= Optional),
               Expression => "",
               Result     => Item.Other_NT (J));
         end if;
      end loop;

      References.Replace_Element (C, Item);
   end Create_NT;

begin
   Kind_To_Function.Initialize;
   Read_XML;
   References.Include (+"compilation_unit", (Flag => Empty_Flag, others => <>));
   References.Iterate (Create_NT'Access);
   References.Iterate (Construct'Access);
   Attribute_Grammars.Print_XML (AG);
end Read;
