with Ada.Containers.Ordered_Sets;
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
   
   procedure Add_Prod_List
     (Prod_List : Production_Index_Vectors.Vector;
      To_Add    : in out League.String_Vectors.Universal_String_Vector);
   
   package String_Sets is new Ada.Containers.Ordered_Sets
     (League.Strings.Universal_String);
   
   Added_T  : String_Sets.Set;
   Added_NT : String_Sets.Set;
   
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
                  Added_T.Insert (Part.Reference);
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
         Added_NT.Insert (Name);
      end if;
      
      Self.Constructor.Create_Non_Terminal (Name);
      
      Add_Prod_List (NT.Element (Name), To_Add);
      
      for J in 1 .. To_Add.Length loop
         Add_NT_Recursive (To_Add.Element (J));
      end loop;
   end Add_NT_Recursive;
begin
   Add_NT_Recursive (Start);
end Complete;
