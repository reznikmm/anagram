------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

package Gela.Grammars.Attributed.Constructors is

   type Constructor is new Attributed.Constructor with private;

   procedure Create_Attribute_Declaration
     (Self      : in out Constructor;
      Name      : S.Universal_String;
      Terminal  : S.Universal_String);
   --  Create new (synt) attribute for terminal

   procedure Set_Current_Non_Terminal
     (Self      : in out Constructor;
      Name      : S.Universal_String);

   procedure Create_Attribute_Declaration
     (Self      : in out Constructor;
      Name      : S.Universal_String;
      Inherited : Boolean);

   procedure Set_Production
     (Self      : in out Constructor;
      Name      : S.Universal_String);

   procedure Create_Rule
     (Self   : in out Constructor;
      Result : S.Universal_String);
   --  Create rule for calculate LHS attribute

   procedure Create_Rule
     (Self   : in out Constructor;
      Part   : S.Universal_String;
      Result : S.Universal_String);
   --  Create rule to calculate RHS attribute in part named Part

   procedure Create_Argument
     (Self      : in out Constructor;
      Name      : S.Universal_String);

   procedure Create_Argument
     (Self      : in out Constructor;
      Name      : S.Universal_String;
      Part      : S.Universal_String);

   function Complete
     (Self : Constructor)
      return Gela.Grammars.Attributed.Grammar;

private

   type Constructor is new Attributed.Constructor with record
      Last_Rule : Nodes.Rule_Key;
   end record;

   function Find_Production
     (Self : Constructor;
      Name : S.Universal_String)
      return Positive;

end Gela.Grammars.Attributed.Constructors;
