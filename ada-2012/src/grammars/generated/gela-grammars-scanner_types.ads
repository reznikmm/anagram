package Gela.Grammars.Scanner_Types is
   pragma Preelaborate;

   type State is mod +153;
   subtype Valid_State is State range 0 .. State'Last - 1;

   INITIAL : constant State := 0;
   In_Rule : constant State := 81;
   With_Regexp : constant State := 84;

   type Character_Class is mod +46;

   type Rule_Index is range 0 .. 30;

end Gela.Grammars.Scanner_Types;
