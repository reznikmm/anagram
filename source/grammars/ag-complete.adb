with Ada.Containers.Ordered_Maps;
with League.Regexps;

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

   procedure Add_Prod_List
     (Prod_List : Production_Index_Vectors.Vector;
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

   Added_T  : String_Maps.Map;
   Added_NT : String_Maps.Map;

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
               Self.Constructor.Set_Current_Non_Terminal (Item);

               Self.Constructor.Create_Attribute_Declaration
                 (Values.Element (J), Inherited);
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
      To_Add : in out League.String_Vectors.Universal_String_Vector) is
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
            Add_Prod_List (Part.Nested, To_Add);
            Self.Constructor.End_List;
         when Option =>
            Self.Constructor.Create_Option (Part.Name);
            Add_Prod_List (Part.Nested, To_Add);
            Self.Constructor.End_List;
      end case;
   end Add_Part;

   procedure Add_Prod
     (Prod   : Production_Node;
      To_Add : in out League.String_Vectors.Universal_String_Vector) is
   begin
      Self.Constructor.Create_Production (Prod.Name);

      for J in Prod.Parts.First_Index .. Prod.Parts.Last_Index loop
         Add_Part (Prod.Parts.Element (J), To_Add);
      end loop;
   end Add_Prod;

   procedure Add_Prod
     (Prod   : Production_Index;
      To_Add : in out League.String_Vectors.Universal_String_Vector) is
   begin
      Add_Prod (Prod_List.Element (Prod), To_Add);
   end Add_Prod;

   procedure Add_Prod_List
     (Prod_List : Production_Index_Vectors.Vector;
      To_Add    : in out League.String_Vectors.Universal_String_Vector) is
   begin
      for J in Prod_List.First_Index .. Prod_List.Last_Index loop
         Add_Prod (Prod_List.Element (J), To_Add);
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

      Add_Prod_List (NT.Element (Name), To_Add);

      for J in 1 .. To_Add.Length loop
         Add_NT_Recursive (To_Add.Element (J));
      end loop;
   end Add_NT_Recursive;
begin
   Add_NT_Recursive (Start);
   Add_Attributes (Inherited, Inherited => True);
   Add_Attributes (Synthesized, Inherited => False);
end Complete;
