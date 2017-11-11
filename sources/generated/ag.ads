-- 1
with League.Strings;
with Anagram.Grammars.Constructors;

package Ag is

   type Parser is tagged limited private;

   procedure Read
     (Self : in out Parser;
      Text : League.Strings.Universal_String;
      Tail_List : Boolean := False);

   function Grammar (Self : in out Parser) return Anagram.Grammars.Grammar;

private

   type Parser is tagged limited record
      Constructor : Anagram.Grammars.Constructors.Constructor;
   end record;
-- 2
end Ag;
