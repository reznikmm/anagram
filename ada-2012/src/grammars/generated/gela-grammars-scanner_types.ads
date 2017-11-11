package Gela.Grammars.Scanner_Types is

   type State is mod 143;
   subtype Valid_State is State range 0 .. State'Last - 1;

   INITIAL : constant State := 0;
   In_Rule : constant State := 76;
   With_Regexp : constant State := 79;

   type Character_Class is mod 44;

   type Rule_Index is range 0 .. 29;

end Gela.Grammars.Scanner_Types;
