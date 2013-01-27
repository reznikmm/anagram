package Gela.Grammars.Scanner_Types is

   type State is mod 149;
   subtype Valid_State is State range 0 .. State'Last - 1;

   INITIAL : constant State := 0;
   In_Rule : constant State := 79;
   With_Regexp : constant State := 82;

   type Character_Class is mod 45;

   type Rule_Index is range 0 .. 30;

end Gela.Grammars.Scanner_Types;
