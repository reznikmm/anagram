------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

package Gela.Grammars.Constructors is

   type Constructor is new Gela.Grammars.Constructor_Base with private;

   procedure Create_Terminal
     (Self  : in out Constructor;
      Image : S.Universal_String);

   procedure Create_Non_Terminal
     (Self : in out Constructor;
      Name : S.Universal_String);

   procedure Create_Production
     (Self : in out Constructor;
      Name : S.Universal_String);

   procedure Create_Terminal_Reference
     (Self   : in out Constructor;
      Name   : S.Universal_String;
      Image  : S.Universal_String);

   procedure Create_Non_Terminal_Reference
     (Self   : in out Constructor;
      Name   : S.Universal_String;
      Denote : S.Universal_String);

   function Complete (Self : Constructor) return Gela.Grammars.Grammar;

private

   type Constructor is new Gela.Grammars.Constructor_Base with null record;

end Gela.Grammars.Constructors;
