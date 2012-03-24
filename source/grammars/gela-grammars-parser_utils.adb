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

   procedure Add_NT
     (Self  : in out Context_Node;
      Name  : League.Strings.Universal_String;
      List  : Production_Index_Vectors.Vector) is
   begin
      if Self.Start.Is_Empty then
         Self.Start := Name;
      end if;

      Self.NT.Insert (Name, List);
   end Add_NT;

   procedure Add_Part
     (Self  : in out Context_Node;
      Index : Production_Index;
      Item  : Part_Node)
   is
      procedure Add (Old : in out Production_Node);

      procedure Add (Old : in out Production_Node) is
      begin
         case Item.Kind is
            when Reference =>
               Old.Refs.Insert (Item.Name, Item.Reference);
            when List =>
               Old.Refs.Insert (Item.Name, Item.Name);
            when Option =>
               declare
                  Refs : Reference_Maps.Map :=
                    Self.Prod_List.Element (Item.Nested.Element (1)).Refs;
               begin
                  for J in 2 .. Item.Nested.Last_Index loop
                     Join
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

   procedure Join
     (Left  : in out Reference_Maps.Map;
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
                  Ada.Wide_Wide_Text_IO.Put_Line
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
          Parts => Part_Vectors.To_Vector (Item, 1)));

      Result := Self.Prod_List.Last_Index;
   end New_Production;

end Gela.Grammars.Parser_Utils;
