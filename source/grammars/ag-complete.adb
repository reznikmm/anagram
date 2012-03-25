with Ada.Containers.Ordered_Maps;
with League.Regexps;
with Gela.Grammars.Rule_Templates;

separate (AG)
procedure Complete
  (Self        : in out Parser;
   Prod_List   : Production_Vectors.Vector;
   Tokens      : League.String_Vectors.Universal_String_Vector;
   NT          : NT_Maps.Map;
   Start       : League.Strings.Universal_String;
   Inherited   : Attribute_Definitions_Vectors.Vector;
   Synthesized : Attribute_Definitions_Vectors.Vector;
   Rules       : Rule_Vectors.Vector)
is
   use type League.Strings.Universal_String;
   use type League.String_Vectors.Universal_String_Vector;

   package Attribute_Maps is new Ada.Containers.Ordered_Maps
     (League.Strings.Universal_String,  --  NT + attr name
      Boolean,                          --  inherited
      League.Strings."<");

   package Production_Maps is new Ada.Containers.Ordered_Maps
     (League.Strings.Universal_String,  --  NT + prod name
      Production_Index,                 --  prod index
      League.Strings."<");

   procedure Add_Prod_List
     (Prod_List : Production_Index_Vectors.Vector;
      Parent    : League.Strings.Universal_String;
      To_Add    : in out League.String_Vectors.Universal_String_Vector);

   package String_Maps is new Ada.Containers.Ordered_Maps
     (League.Strings.Universal_String,
      League.String_Vectors.Universal_String_Vector);

   procedure Add_Attributes
     (List      : Attribute_Definitions_Vectors.Vector;
      Inherited : Boolean);

   procedure Add_Attributes
     (Name      : League.Strings.Universal_String;
      Values    : League.String_Vectors.Universal_String_Vector;
      Inherited : Boolean);

   procedure Add_Rules;

   procedure Add_Rule
     (Template : Gela.Grammars.Rule_Templates.Rule_Template;
      Regexp   : League.Regexps.Regexp_Pattern);

   procedure Create_Rule
     (NT       : League.Strings.Universal_String;
      Prod     : Production_Node;
      Template : Gela.Grammars.Rule_Templates.Rule_Template);

   procedure Add_Rules is
   begin
      for J in Rules.First_Index .. Rules.Last_Index loop
         declare
            Regexp   : League.Regexps.Regexp_Pattern;
            Item     : constant Rule_Node := Rules.Element (J);
            Template : constant Gela.Grammars.Rule_Templates.Rule_Template :=
              Gela.Grammars.Rule_Templates.Create (Item.Image);
         begin
            for K in 1 .. Item.Regexps.Length loop
               Regexp := League.Regexps.Compile
                 ("^" & Item.Regexps.Element (K) & "$");
               Add_Rule (Template, Regexp);
            end loop;
         end;
      end loop;
   end Add_Rules;

   Added_T    : String_Maps.Map;  --  Map term to attr names
   Added_NT   : String_Maps.Map;  --  Map NT to attr names
   Added_Prod : Production_Maps.Map;
   Added_Attr : Attribute_Maps.Map;   --  Map attr to inherited

   procedure Create_Rule
     (NT       : League.Strings.Universal_String;
      Prod     : Production_Node;
      Template : Gela.Grammars.Rule_Templates.Rule_Template)
   is
      function Is_Result (Index : Positive) return Boolean;

      Found    : Boolean := True;

      function Is_Result (Index : Positive) return Boolean is
         Name : League.Strings.Universal_String;
         Inherited : Boolean;
      begin
         if Template.Part_Name (Index) = NT then
            Name := NT;
         elsif not Prod.Refs.Contains (Template.Part_Name (Index)) then
            Found := False;
            return False;
         else
            Name := Prod.Refs.Element (Template.Part_Name (Index));
         end if;

         Inherited := Added_Attr
           (Name & "." & Template.Attribute_Name (Index));

         return Template.Part_Name (Index) = NT xor Inherited;
      end Is_Result;

      Index    : Natural := 0;
   begin
      for J in 1 .. Template.Count loop
         if Is_Result (J) then
            if Index /= 0 then
               Ada.Wide_Wide_Text_IO.Put_Line
                 ("Too many result in rule");
               return;
            else
               Index := J;
            end if;
         end if;
      end loop;

      if not Found then
         return;
      elsif Index = 0 then
         Ada.Wide_Wide_Text_IO.Put_Line
           ("No result in rule");
         return;
      elsif Template.Part_Name (Index) = NT then
         Self.Constructor.Create_Rule
           (Template.Attribute_Name (Index));
      else
         Self.Constructor.Create_Rule
           (Template.Part_Name (Index),
            Template.Attribute_Name (Index));
      end if;

      for J in 1 .. Template.Count loop
         if J /= Index then
            if Template.Part_Name (J) = NT then
               Self.Constructor.Create_Argument
                 (Template.Attribute_Name (J));
            else
               Self.Constructor.Create_Argument
                 (Part => Template.Part_Name (J),
                  Name => Template.Attribute_Name (J));
            end if;
         end if;
      end loop;
   end Create_Rule;

   procedure Add_Rule
     (Template : Gela.Grammars.Rule_Templates.Rule_Template;
      Regexp   : League.Regexps.Regexp_Pattern)
   is
      use Production_Maps;
      NT   : League.Strings.Universal_String;
      Name : League.Strings.Universal_String;
      Pos  : Cursor := Added_Prod.First;
   begin
      while Has_Element (Pos) loop
         Name := Key (Pos);

         if Regexp.Find_Match (Name).Is_Matched then
            declare
               Index : Production_Index := Element (Pos);
               List : League.String_Vectors.Universal_String_Vector :=
                 Name.Split ('-');
            begin
               NT := List.Element (1);
               Self.Constructor.Set_Current_Non_Terminal (NT);
               Self.Constructor.Set_Production (Name);

               Create_Rule (NT, Prod_List.Element (Index), Template);
            end;
         end if;

         Pos := Next (Pos);
      end loop;
   end Add_Rule;

   procedure Add_Attributes
     (List      : Attribute_Definitions_Vectors.Vector;
      Inherited : Boolean) is
   begin
      for J in List.First_Index .. List.Last_Index loop
         declare
            Item : constant Attribute_Definitions := List.Element (J);
         begin
            for K in 1 .. Item.Names.Length loop
               Add_Attributes
                 (Item.Names.Element (K),
                  Item.Values,
                  Inherited);
            end loop;
         end;
      end loop;
   end Add_Attributes;

   procedure Add_Attributes
     (Name      : League.Strings.Universal_String;
      Values    : League.String_Vectors.Universal_String_Vector;
      Inherited : Boolean)
   is
      procedure Append
        (Key  : League.Strings.Universal_String;
         List : in out League.String_Vectors.Universal_String_Vector) is
      begin
         List.Prepend (Values);
      end Append;

      Regexp : League.Regexps.Regexp_Pattern;
      Cursor : String_Maps.Cursor := Added_NT.First;
      Item   : League.Strings.Universal_String;
   begin
      Regexp := League.Regexps.Compile (Name);

      while String_Maps.Has_Element (Cursor) loop
         Item := String_Maps.Key (Cursor);

         if Regexp.Find_Match (Item).Is_Matched then

            for J in 1 .. Values.Length loop
               Added_NT.Update_Element (Cursor, Append'Access);

               Added_Attr.Insert
                 (Item & "." & Values.Element (J), Inherited);

               Self.Constructor.Set_Current_Non_Terminal (Item);

               Self.Constructor.Create_Attribute_Declaration
                 (Values.Element (J), Inherited);
            end loop;
         end if;

         Cursor := String_Maps.Next (Cursor);
      end loop;

      if Inherited then
         return;
      end if;

      Cursor := Added_T.First;

      while String_Maps.Has_Element (Cursor) loop
         Item := String_Maps.Key (Cursor);

         if Regexp.Find_Match (Item).Is_Matched then

            for J in 1 .. Values.Length loop
               Added_T.Update_Element (Cursor, Append'Access);

               Added_Attr.Insert
                 (Item & "." & Values.Element (J), False);

               Self.Constructor.Create_Attribute_Declaration
                 (Values.Element (J),
                  Terminal => Item);
            end loop;
         end if;

         Cursor := String_Maps.Next (Cursor);
      end loop;

   exception
      when E : Constraint_Error =>
         Ada.Wide_Wide_Text_IO.Put_Line
           ("Constraint_Error while compiling regexp:"
              & Name.To_Wide_Wide_String);
   end Add_Attributes;

   procedure Add_Part
     (Part   : Part_Node;
      Parent : League.Strings.Universal_String;
      To_Add : in out League.String_Vectors.Universal_String_Vector;
      Parts  : in out League.String_Vectors.Universal_String_Vector) is
   begin
      case Part.Kind is
         when Reference =>
            if NT.Contains (Part.Reference) then
               Self.Constructor.Create_Non_Terminal_Reference
                 (Name   => Part.Name,
                  Denote => Part.Reference);

               if not Added_NT.Contains (Part.Reference) then
                  To_Add.Append (Part.Reference);
               end if;
            elsif Tokens.Index (Part.Reference) > 0 then
               Self.Constructor.Create_Terminal_Reference
                 (Name  => Part.Name,
                  Image => Part.Reference);

               if not Added_T.Contains (Part.Reference) then
                  Added_T.Insert
                    (Part.Reference,
                     League.String_Vectors.Empty_Universal_String_Vector);

                  Self.Constructor.Create_Terminal (Part.Reference);
               end if;
            else
               Ada.Wide_Wide_Text_IO.Put_Line
                 ("Unknown reference " & Part.Reference.To_Wide_Wide_String);
            end if;
         when List =>
            Self.Constructor.Create_List (Part.Name);
            Add_Prod_List (Part.Nested, Parent & "-" & Part.Name, To_Add);
            Self.Constructor.End_List;
         when Option =>
            Self.Constructor.Create_Option (Part.Name);
            Add_Prod_List (Part.Nested, Parent, To_Add);
            Self.Constructor.End_List;
      end case;

      Parts.Append (Part.Name);
   end Add_Part;

   procedure Add_Prod
     (Prod   : Production_Node;
      Parent : League.Strings.Universal_String;
      To_Add : in out League.String_Vectors.Universal_String_Vector;
      Index  : Production_Index)
   is
      Parts     : League.String_Vectors.Universal_String_Vector;
      Prod_Name : constant League.Strings.Universal_String :=
        Parent & "-" & Prod.Name;
   begin
      Self.Constructor.Create_Production (Prod_Name);

      for J in Prod.Parts.First_Index .. Prod.Parts.Last_Index loop
         Add_Part (Prod.Parts.Element (J), Prod_Name, To_Add, Parts);
      end loop;

      Added_Prod.Insert (Prod_Name, Index);
   end Add_Prod;

   procedure Add_Prod
     (Prod   : Production_Index;
      Parent : League.Strings.Universal_String;
      To_Add : in out League.String_Vectors.Universal_String_Vector) is
   begin
      Add_Prod (Prod_List.Element (Prod), Parent, To_Add, Prod);
   end Add_Prod;

   procedure Add_Prod_List
     (Prod_List : Production_Index_Vectors.Vector;
      Parent    : League.Strings.Universal_String;
      To_Add    : in out League.String_Vectors.Universal_String_Vector) is
   begin
      for J in Prod_List.First_Index .. Prod_List.Last_Index loop
         Add_Prod (Prod_List.Element (J), Parent, To_Add);
      end loop;
   end Add_Prod_List;

   procedure Add_NT_Recursive (Name : League.Strings.Universal_String) is
      To_Add    : League.String_Vectors.Universal_String_Vector;
   begin
      if Added_NT.Contains (Name) then
         return;
      else
         Added_NT.Insert
           (Name,
            League.String_Vectors.Empty_Universal_String_Vector);
      end if;

      Self.Constructor.Create_Non_Terminal (Name);

      Add_Prod_List (NT.Element (Name), Name, To_Add);

      for J in 1 .. To_Add.Length loop
         Add_NT_Recursive (To_Add.Element (J));
      end loop;
   end Add_NT_Recursive;
begin
   Add_NT_Recursive (Start);
   Add_Attributes (Inherited, Inherited => True);
   Add_Attributes (Synthesized, Inherited => False);
   Add_Rules;
end Complete;
