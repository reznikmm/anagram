------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

package body Gela.Grammars.Attributed.Extended is

   -------------
   -- Is_List --
   -------------

   function Is_List (Self : access Part) return Boolean is
   begin
      return Self.Is_List;
   end Is_List;

   ---------------
   -- Is_Option --
   ---------------

   function Is_Option (Self : access Part) return Boolean is
   begin
      return Self.Is_Option;
   end Is_Option;

   -----------
   -- First --
   -----------

   function First (Self : access Part) return Production_Index is
   begin
      return Self.First;
   end First;

   ----------
   -- Last --
   ----------

   function Last (Self : access Part) return Production_Count is
   begin
      return Self.Last;
   end Last;

   -----------
   -- First --
   -----------

   function First (Self : access Part) return Attribute_Declaration_Index is
   begin
      return Self.First_Attribute;
   end First;

   ----------
   -- Last --
   ----------

   function Last (Self : access Part) return Attribute_Declaration_Count is
   begin
      return Self.Last_Attribute;
   end Last;

end Gela.Grammars.Attributed.Extended;
