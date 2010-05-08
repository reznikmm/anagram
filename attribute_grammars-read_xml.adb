with Ada.Strings.Unbounded;

with Attribute_Grammars.Construction;
use Attribute_Grammars.Construction;

with Ada.Text_IO;

with Text_Streams.File;
with XML_IO.Stream_Readers;

package body Attribute_Grammars.Read_XML is

   package Enum is
      type Element_Kinds is
        (Attribute_Grammar,
         Nonterminal,
         Production,
         Attribute_Declaration,
         Argument,
         Part,
         Rule,
         Text);
   end Enum;

   procedure Read
     (File_Name : in String;
      Result    : out Attribute_Grammar)
   is
      use XML_IO;
      use Ada.Strings.Unbounded;

      package R renames XML_IO.Stream_Readers;

      type Part_Patch;
      type Attr_Patch;

      type Part_Patch_Access is access all Part_Patch;
      type Attr_Patch_Access is access all Attr_Patch;

      type Part_Patch is record
         The_Part : Part;
         NT_Name  : Unbounded_String;
         Next     : Part_Patch_Access;
      end record;

      type Attr_Patch is record
         Attr   : Attribute;
         Name   : Unbounded_String;
         Is_LHS : Boolean;
         Next   : Attr_Patch_Access;
      end record;

      Stream   : aliased Text_Streams.File.File_Text_Stream;
      Parser   : R.Reader (Stream'Access, R.Default_Buffer_Size);
      Kind     : Enum.Element_Kinds;
      NT       : Nonterminal;
      Prod     : Production;
      Decl     : Attribute_Declaration;
      The_Part : Part;
      The_Rule : Rule;
      Attr     : Attribute;
      NT_Name  : Unbounded_String;

      Part_Patch_List : Part_Patch_Access;
      Attr_Patch_List : Attr_Patch_Access;

      procedure Push (Attr : Attribute; Is_LHS : Boolean := False) is
         Name : constant String :=
           R.Attribute_Value (Parser, "attribute", Raise_Error => True);
         U    : Unbounded_String := To_Unbounded_String (Name);
      begin
         Attr_Patch_List := new Attr_Patch'(Attr, U, Is_LHS, Attr_Patch_List);
      end Push;

      procedure Patch
        (Attr   : in out Attribute;
         Name   : String;
         Is_LHS : Boolean)
      is
         NT   : Nonterminal;
         Decl : Attribute_Declaration;
      begin
         if Left_Hand_Side (Attr) then
            NT := Parent (Parent (Parent (Attr)));
         else
            NT := Reference (Origin (Attr));
         end if;

         Decl := Find (NT, Name);

         Set_Declaration (Attr, Decl);

         if Is_LHS then
            Decl.Is_Inherited := False;
         end if;
      exception
         when Not_Found =>
            Ada.Text_IO.Put_Line
              ("Attribute isn't found:" & Name);
      end Patch;

   begin
      Text_Streams.File.Open (Stream, File_Name);
      R.Initialize (Parser);

      while R.More_Pieces (Parser) loop
         case R.Piece_Kind (Parser) is
            when Start_Element =>
               Kind := Enum.Element_Kinds'Value (R.Name (Parser));

               case Kind is
                  when Enum.Attribute_Grammar =>
                     Result := Create;
                  when Enum.Nonterminal =>
                     Create (Result,
                             Name   => R.Attribute_Value
                                      (Parser, "name", Raise_Error => True),
                             Type_Name => R.Attribute_Value
                                      (Parser, "type", Raise_Error => True),
                             Expression => R.Attribute_Value (Parser, "case"),
                             Result => NT);
                  when Enum.Production =>
                     Create (NT,
                             Kind => R.Attribute_Value (Parser, "kind"),
                             Result => Prod);
                  when Enum.Attribute_Declaration =>
                     Create (NT,
                             Name   => R.Attribute_Value
                                      (Parser, "name", Raise_Error => True),
                             Type_Name => R.Attribute_Value
                                      (Parser, "type", Raise_Error => True),
                             Result => Decl);
                  when Enum.Part =>
                     Create (Prod,
                             Name   => R.Attribute_Value
                                      (Parser, "name", Raise_Error => True),
                             Result => The_Part);

                     NT_Name := To_Unbounded_String
                       (R.Attribute_Value (Parser, "reference",
                                           Raise_Error => True));

                     Part_Patch_List :=
                       new Part_Patch'(The_Part, NT_Name, Part_Patch_List);

                  when Enum.Rule =>
                     declare
                        Part_Name : constant String :=
                          R.Attribute_Value (Parser, "part");
                     begin
                        Create (Prod, The_Rule);

                        if Part_Name = "" then
                           Create_Result (The_Rule, Attr);
                           Push (Attr, True);
                        else
                           Create_Result
                             (The_Rule, Attr, Find (Prod, Part_Name));
                           Push (Attr);
                        end if;
                     end;
                  when Enum.Argument =>
                     declare
                        Part_Name : constant String :=
                          R.Attribute_Value (Parser, "part");
                     begin
                        if Part_Name = "" then
                           Create_Argument (The_Rule, Attr);
                        else
                           Create_Argument
                             (The_Rule, Attr, Find (Prod, Part_Name));
                        end if;

                        Push (Attr);
                     end;
                  when Enum.Text =>
                     R.Next (Parser);
                     if R.Piece_Kind (Parser) = Characters then
                        Set_Text (The_Rule, R.Text (Parser));
                     else
                        raise Constraint_Error with "text expected";
                     end if;
               end case;
            when others =>
               null;
         end case;

         R.Next (Parser);
      end loop;

      while Part_Patch_List /= null loop
         Set_Reference (Part_Patch_List.The_Part,
                        Find (Result, To_String (Part_Patch_List.NT_Name)));

         Part_Patch_List := Part_Patch_List.Next;
      end loop;

      while Attr_Patch_List /= null loop
         Patch (Attr_Patch_List.Attr,
                To_String (Attr_Patch_List.Name),
                Attr_Patch_List.Is_LHS);

         Attr_Patch_List := Attr_Patch_List.Next;
      end loop;
   end Read;

end Attribute_Grammars.Read_XML;

