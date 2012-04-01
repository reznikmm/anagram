------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Gela.Grammars.Common;

package body Gela.Grammars.Constructors is

   ---------------------
   -- Create_Terminal --
   ---------------------

   procedure Create_Terminal
     (Self  : in out Constructor;
      Image : S.Universal_String)
   is
   begin
      Self.Terminals.Insert (Image, null);
   end Create_Terminal;

   -------------------------
   -- Create_Non_Terminal --
   -------------------------

   procedure Create_Non_Terminal
     (Self : in out Constructor;
      Name : S.Universal_String) is
   begin
      if Self.Root.Is_Empty then
         Self.Root := Name;
      end if;

      Self.Non_Terminals.Insert (Name, null);
      Self.Last_Production := ((Name, 0), 1);
   end Create_Non_Terminal;

   -----------------------
   -- Create_Production --
   -----------------------

   procedure Create_Production
     (Self : in out Constructor;
      Name : S.Universal_String)
   is
      Last : constant Natural := Natural (Self.Productions.Length);
   begin
      Self.Last_Production.Production_Index := Last + 1;

      Self.Productions.Insert (Self.Last_Production, (Name => Name));
   end Create_Production;

   -------------------------------
   -- Create_Terminal_Reference --
   -------------------------------

   procedure Create_Terminal_Reference
     (Self   : in out Constructor;
      Name   : S.Universal_String;
      Image  : S.Universal_String)
   is
      Last_Part : Constructor_Nodes.Part_Key;
   begin
      Last_Part := (Self.Last_Production, Natural (Self.Parts.Length) + 1);
      Self.Parts.Insert (Last_Part, (True, Name, Image, 0, 0));
   end Create_Terminal_Reference;

   -----------------------------------
   -- Create_Non_Terminal_Reference --
   -----------------------------------

   procedure Create_Non_Terminal_Reference
     (Self   : in out Constructor;
      Name   : S.Universal_String;
      Denote : S.Universal_String)
   is
      Last_Part : Constructor_Nodes.Part_Key;
   begin
      Last_Part := (Self.Last_Production, Natural (Self.Parts.Length) + 1);
      Self.Parts.Insert (Last_Part, (False, Name, Denote, 0, 0));
   end Create_Non_Terminal_Reference;

   --------------
   -- Complete --
   --------------

   function Complete (Self : Constructor) return Gela.Grammars.Grammar is
      use Gela.Grammars.Common;

      procedure Copy_Base_Parts is
        new Constructor_Nodes.Generic_Copy_Parts
          (Part, Part_Array, Constructor_Nodes.New_Part);

   begin
      return Result : Gela.Grammars.Grammar
        (Last_Terminal     => Terminal_Count (Self.Terminals.Length),
         Last_Non_Terminal => Non_Terminal_Count (Self.Non_Terminals.Length),
         Last_Production   => Production_Count (Self.Productions.Length),
         Last_Part         => Part_Count (Self.Parts.Length))
      do
         Copy_Terminals (Self.Self.all, Result.Terminal);
         Copy_Non_Terminals (Self.Self.all, Result.Non_Terminal);
         Copy_Productions (Self.Self.all, Result.Production);

         Copy_Base_Parts
           (Self.Self.all,
            Result.Part);

         Result.Root := Self.Non_Terminals.Element (Self.Root).Index;
      end return;
   end Complete;

end Gela.Grammars.Constructors;
