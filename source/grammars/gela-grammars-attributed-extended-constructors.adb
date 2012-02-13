------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

package body Gela.Grammars.Attributed.Extended.Constructors is

   procedure On_Extended_Attribute
     (Self : Gela.Grammars.Attributed.Constructor'Class;
      Key  : Nodes.Declaration_Key;
      Item : Nodes.Declaration_Access);

   -----------------
   -- Create_List --
   -----------------

   procedure Create_List
     (Self : in out Constructor;
      Name : S.Universal_String)
   is
      Last_Part : Constructor_Nodes.Part_Key;
   begin
      Last_Part := (Self.Last_Production, Natural (Self.Parts.Length) + 1);

      Self.Last_Extension := Self.Last_Extension + 1;

      Self.Parts.Insert
        (Last_Part,
         (False, Name, S.Empty_Universal_String,
          List_Extension   => Self.Last_Extension,
          Option_Extension => 0));

      Self.Stack.Append (Self.Last_Production);
      Self.Last_Production :=
        ((S.Empty_Universal_String, Self.Last_Extension), 1);
   end Create_List;

   ----------------------
   -- Set_Current_List --
   ----------------------

   procedure Set_Current_List
     (Self      : in out Constructor;
      Name      : S.Universal_String)
   is
      Key : constant Constructor_Nodes.Part_Key := Find_Part (Self, Name);
      Node : constant Constructor_Nodes.Part_Node := Self.Parts.Element (Key);
   begin
      if Node.List_Extension > 0 then
         Self.Last_Production :=
           ((S.Empty_Universal_String, Node.List_Extension), 1);
      else
         raise Constraint_Error;
      end if;
   end Set_Current_List;

   --------------
   -- End_List --
   --------------

   procedure End_List (Self  : in out Constructor) is
   begin
      Self.Last_Production := Self.Stack.Last_Element;
      Self.Stack.Delete_Last;
   end End_List;

   -------------------
   -- Create_Option --
   -------------------

   procedure Create_Option
     (Self : in out Constructor;
      Name : S.Universal_String)
   is
      Last_Part : Constructor_Nodes.Part_Key;
   begin
      Last_Part := (Self.Last_Production, Natural (Self.Parts.Length) + 1);

      Self.Last_Extension := Self.Last_Extension + 1;

      Self.Parts.Insert
        (Last_Part,
         (False, Name, S.Empty_Universal_String,
          List_Extension   => 0,
          Option_Extension => Self.Last_Extension));

      Self.Stack.Append (Self.Last_Production);
      Self.Last_Production :=
        ((S.Empty_Universal_String, Self.Last_Extension), 1);
   end Create_Option;

   ----------------
   -- End_Option --
   ----------------

   procedure End_Option (Self  : in out Constructor) is
   begin
      Self.Last_Production := Self.Stack.Last_Element;
      Self.Stack.Delete_Last;
   end End_Option;

   --------------
   -- Complete --
   --------------

   function Complete
     (Self : Constructor)
      return Gela.Grammars.Attributed.Extended.Grammar
   is
      procedure Fill_Ext (Parts : in out Part_Array);

      procedure New_Part
        (Node   : Constructor_Nodes.Part_Node;
         Result : in out Part'Class);

      procedure Fill_Ext (Parts : in out Part_Array) is
         use Constructor_Nodes;
         Extension : Natural;
         Index  : Part_Index;
         Cursor : Production_Maps.Cursor := Self.Productions.First;
      begin
         while Production_Maps.Has_Element (Cursor) loop
            Extension := Production_Maps.Key (Cursor).Parent.Extension;
            exit when Extension = 0;

            Index := Self.Ext_Map.Element (Extension);
            declare
               Prod   : Production'Class renames
                 Production'Class
                   (Self.Prod_Map.Element (Production_Maps.Key
                     (Cursor).Production_Index).all);
            begin
               if Parts (Index).Last = 0 then
                  Parts (Index).First := Prod.Index;
               end if;

               Parts (Index).Last := Prod.Index;
            end;

            Cursor := Production_Maps.Next (Cursor);
         end loop;
      end Fill_Ext;

      procedure New_Part
        (Node   : Constructor_Nodes.Part_Node;
         Result : in out Part'Class) is
      begin
         Result.Is_List := False;
         Result.Is_Option := False;

         if Node.List_Extension > 0 or Node.Option_Extension > 0 then
            Result.Is_Terminal_Reference := False;
            Result.Is_Non_Terminal_Reference := False;
            Result.Denoted_Terminal := 0;
            Result.Denoted_Non_Terminal := 0;
            Result.Is_List := Node.List_Extension > 0;
            Result.Is_Option := Node.Option_Extension > 0;
            Result.First := 1;
            Result.Last := 0;
            Self.Self.Ext_Map.Insert
              (Node.List_Extension + Node.Option_Extension, Result.Index);
         else
            Constructor_Nodes.New_Part (Node, Result);
         end if;
      end New_Part;

      procedure Copy_Ext_Parts is
        new Constructor_Nodes.Generic_Copy_Parts (Part, Part_Array, New_Part);

      Parent : Attributed.Constructor renames
        Attributed.Constructor (Self.Self.all);
      Decls : constant Attribute_Declaration_Count :=
        Attribute_Declaration_Count (Parent.Declarations.Length);
   begin
      Parent.On_Extended_Attr := On_Extended_Attribute'Access;

      return Result : Gela.Grammars.Attributed.Extended.Grammar
        (Last_Terminal     => Terminal_Count (Self.Terminals.Length),
         Last_Non_Terminal => Non_Terminal_Count (Self.Non_Terminals.Length),
         Last_Production   => Production_Count (Self.Productions.Length),
         Last_Part         => Part_Count (Self.Parts.Length),
         Last_Declaration  => Decls,
         Last_Attribute    => Attribute_Count (Parent.Attributes.Length),
         Last_Rule         => Rule_Count (Parent.Rules.Length))
      do
         Nodes.Copy_Terminals (Self.Self.all, Result.Terminal);
         Nodes.Copy_Non_Terminals (Self.Self.all, Result.Non_Terminal);
         Nodes.Copy_Productions (Self.Self.all, Result.Production);

         Copy_Ext_Parts
           (Self.Self.all,
            Result.Part);

         Parent.Copy_Declarations (Result.Declaration);

         Parent.Copy_Rules (Result.Rule);

         Parent.Copy_Attributes (Result.Attribute);

         Fill_Ext (Result.Part);
      end return;
   end Complete;

   ---------------------------
   -- On_Extended_Attribute --
   ---------------------------

   procedure On_Extended_Attribute
     (Self : Gela.Grammars.Attributed.Constructor'Class;
      Key  : Nodes.Declaration_Key;
      Item : Nodes.Declaration_Access)
   is
      function Find_List return Constructor_Nodes.Part_Access;

      function Find_List return Constructor_Nodes.Part_Access is
         use Constructor_Nodes;

         X : Part_Maps.Cursor := Self.Parts.First;
      begin
         while Part_Maps.Has_Element (X) loop
            if Part_Maps.Element (X).List_Extension = Key.Parent.Extension then
               return Self.Part_Map.Element (Part_Maps.Key (X).Part_Index);
            end if;

            X := Part_Maps.Next (X);
         end loop;

         raise Constraint_Error;
      end Find_List;

      List : Part renames Part (Find_List.all);
   begin
      if List.Last_Attribute = 0 then
         List.First_Attribute := Item.Index;
      end if;

      List.Last_Attribute := Item.Index;
   end On_Extended_Attribute;

end Gela.Grammars.Attributed.Extended.Constructors;
