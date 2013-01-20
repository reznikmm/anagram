package Gela.Grammars.Scanner_Types is

   type State is mod 131;
   subtype Valid_State is State range 0 .. State'Last - 1;

   INITIAL : constant State := 0;
   In_Rule : constant State := 70;
   With_Regexp : constant State := 73;

   type Character_Class is mod 43;

   type Rule_Index is range 0 .. 28;

end Gela.Grammars.Scanner_Types;
