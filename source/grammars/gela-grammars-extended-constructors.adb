------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Gela.Grammars.Common;

package body Gela.Grammars.Extended.Constructors is

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
      return Gela.Grammars.Extended.Grammar
   is
      use Gela.Grammars.Common;

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
                 Self.Prod_Map.Element (Production_Maps.Key
                                        (Cursor).Production_Index).all;
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

   begin
      return Result : Gela.Grammars.Extended.Grammar
        (Last_Terminal     => Terminal_Count (Self.Terminals.Length),
         Last_Non_Terminal => Non_Terminal_Count (Self.Non_Terminals.Length),
         Last_Production   => Production_Count (Self.Productions.Length),
         Last_Part         => Part_Count (Self.Parts.Length))
      do
         Copy_Terminals (Self.Self.all, Result.Terminal);

         Copy_Non_Terminals (Self.Self.all, Result.Non_Terminal);

         Copy_Productions (Self.Self.all, Result.Production);

         Copy_Ext_Parts
           (Self.Self.all,
            Result.Part);

         Fill_Ext (Result.Part);
      end return;
   end Complete;

end Gela.Grammars.Extended.Constructors;
