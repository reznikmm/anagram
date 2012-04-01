------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

package Gela.Grammars.Extended is

   type Part is new Gela.Grammars.Part with private;

   function Is_List   (Self : access Part) return Boolean;
   function Is_Option (Self : access Part) return Boolean;
   function First     (Self : access Part) return Production_Index;
   function Last      (Self : access Part) return Production_Count;

   type Part_Array is array (Part_Index range <>) of aliased Part;

   type Grammar
     (Last_Terminal     : Terminal_Count;
      Last_Non_Terminal : Non_Terminal_Count;
      Last_Production   : Production_Count;
      Last_Part         : Part_Count) is
   tagged limited record
      Root         : Non_Terminal_Index;
      Terminal     : Terminal_Array     (1 .. Last_Terminal);
      Non_Terminal : Non_Terminal_Array (1 .. Last_Non_Terminal);
      Production   : Production_Array   (1 .. Last_Production);
      Part         : Part_Array         (1 .. Last_Part);
   end record;

private
   type Part is new Gela.Grammars.Part with record
      Is_List   : Boolean;
      Is_Option : Boolean;
      First     : Production_Index;
      Last      : Production_Count;
   end record;
end Gela.Grammars.Extended;
