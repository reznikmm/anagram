------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------
with Ada.Wide_Wide_Text_IO;

package body Gela.Grammars.Parser_Utils is

   ------------
   -- Add_NT --
   ------------

   procedure Add_NT
     (Self  : in out Context_Node;
      Name  : League.Strings.Universal_String;
      List  : Production_Index_Vectors.Vector)
   is
      Ok     : Boolean;
      Ignore : NT_Maps.Cursor;
   begin
      if Self.Start.Is_Empty then
         Self.Start := Name;
      end if;

      Self.NT.Insert (Name, List, Ignore, Ok);

      if not Ok then
         Self.Error ("Duplicate Non Terminal: " & Name.To_Wide_Wide_String);
      end if;
   end Add_NT;

   procedure Add_Part
     (Self  : in out Context_Node;
      Index : Production_Index;
      Item  : Part_Node)
   is
      procedure Add (Old : in out Production_Node);

      procedure Add (Old : in out Production_Node) is
         Ok     : Boolean;
         Ignore : Reference_Maps.Cursor;
      begin
         case Item.Kind is
            when Reference =>
               Old.Refs.Insert (Item.Name, Item.Reference, Ignore, Ok);

               if not Ok then
                  Self.Error
                    ("Duplicate name: " & Item.Name.To_Wide_Wide_String);
               end if;
            when List =>
               Old.Refs.Insert (Item.Name, Item.Name, Ignore, Ok);

               if not Ok then
                  Self.Error
                    ("Duplicate name: " & Item.Name.To_Wide_Wide_String);
               end if;
            when Option =>
               declare
                  Refs : Reference_Maps.Map :=
                    Self.Prod_List.Element (Item.Nested.Element (1)).Refs;
               begin
                  for J in 2 .. Item.Nested.Last_Index loop
                     Self.Join
                       (Refs,
                        Self.Prod_List.Element
                          (Item.Nested.Element (J)).Refs);
                  end loop;

                  Append (Old.Refs, Refs);
               end;
         end case;

         Old.Parts.Append (Item);
      end Add;
   begin
      Self.Prod_List.Update_Element (Index, Add'Access);
   end Add_Part;

   --------------------
   -- Add_Production --
   --------------------

   procedure Add_Production
     (Self  : in out Context_Node;
      List  : in out Production_Index_Vectors.Vector;
      Item  : Production_Index)
   is
      use type League.Strings. Universal_String;

      Node : constant Production_Node := Self.Prod_List.Element (Item);
   begin
      for J in List.First_Index .. List.Last_Index loop
         declare
            Index : constant Production_Index := List.Element (J);
         begin
            if Self.Prod_List.Element (Index).Name = Node.Name then
               Self.Error ("Duplicated production name: " &
                             Node.Name.To_Wide_Wide_String);
               return;
            end if;
         end;
      end loop;

      List.Append (Item);
   end Add_Production;

   ---------------
   -- Add_Token --
   ---------------

   procedure Add_Token
     (Self  : in out Context_Node;
      Image : League.Strings.Universal_String) is
   begin
      if not Self.Tokens.Is_Empty and then Self.Tokens.Index (Image) > 0 then
         Self.Error ("Dublicate token: " & Image.To_Wide_Wide_String);
      end if;

      Self.Tokens.Append (Image);
   end Add_Token;

   procedure Append
     (Left  : in out Reference_Maps.Map;
      Right : Reference_Maps.Map)
   is
      Pos : Reference_Maps.Cursor := Right.First;
   begin
      while Reference_Maps.Has_Element (Pos) loop
         Left.Insert (Reference_Maps.Key (Pos),
                      Reference_Maps.Element (Pos));
         Reference_Maps.Next (Pos);
      end loop;
   end Append;

   -----------
   -- Error --
   -----------

   procedure Error
     (Self  : in out Context_Node;
      Text  : Wide_Wide_String) is
   begin
      Ada.Wide_Wide_Text_IO.Put_Line (Text);
      Self.Errors := True;
   end Error;

   procedure Join
     (Self  : in out Context_Node;
      Left  : in out Reference_Maps.Map;
      Right : Reference_Maps.Map)
   is
      use League.Strings;
      Pos : Reference_Maps.Cursor := Right.First;
   begin
      while Reference_Maps.Has_Element (Pos) loop
         declare
            X : constant League.Strings.Universal_String :=
              Reference_Maps.Key (Pos);
            Y : constant League.Strings.Universal_String :=
              Reference_Maps.Element (Pos);
         begin
            if Left.Contains (X) then
               if Left.Element (X) /= Y then
                  Self.Error
                    ("Dublicate name: " & X.To_Wide_Wide_String &
                       " refs " & Left.Element (X).To_Wide_Wide_String &
                       " and " & Y.To_Wide_Wide_String);
               end if;
            else
               Left.Insert (X, Y);
            end if;

            Reference_Maps.Next (Pos);
         end;
      end loop;
   end Join;

   procedure Set_Name
     (Self  : in out Context_Node;
      Index : Production_Index;
      Name  : League.Strings.Universal_String)
   is
      procedure Set (Old : in out Production_Node);

      procedure Set (Old : in out Production_Node) is
      begin
         Old.Name := Name;
      end Set;
   begin
      Self.Prod_List.Update_Element (Index, Set'Access);
   end Set_Name;

   procedure New_Production
     (Self   : in out Context_Node;
      Item   : Part_Node;
      Result : out  Production_Index) is
   begin
      Self.Prod_List.Append
        ((Name  => <>,
          Refs  => <>,
          Parts => <>));

      Result := Self.Prod_List.Last_Index;
      Self.Add_Part (Result, Item);
   end New_Production;

end Gela.Grammars.Parser_Utils;
