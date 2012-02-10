------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with Gela.Grammars.Attributed.Constructors;
private with Ada.Containers.Doubly_Linked_Lists;

package Gela.Grammars.Attributed.Extended.Constructors is

   type Constructor is new Gela.Grammars.Attributed.Constructors.Constructor
     with private;

   procedure Create_List
     (Self : in out Constructor;
      Name : S.Universal_String);

   procedure Set_Current_List
     (Self      : in out Constructor;
      Name      : S.Universal_String);

   procedure End_List (Self  : in out Constructor);

   procedure Create_Option
     (Self : in out Constructor;
      Name : S.Universal_String);

   procedure End_Option (Self  : in out Constructor);

   function Complete
     (Self : Constructor)
      return Gela.Grammars.Attributed.Extended.Grammar;

private

   package Stacks is new Ada.Containers.Doubly_Linked_Lists
     (Constructor_Nodes.Production_Key, Constructor_Nodes."=");

   type Constructor is
     new Gela.Grammars.Attributed.Constructors.Constructor with record
        Last_Extension : Natural := 0;
        Stack          : Stacks.List;
   end record;

end Gela.Grammars.Attributed.Extended.Constructors;
