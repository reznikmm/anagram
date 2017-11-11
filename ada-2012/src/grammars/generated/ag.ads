-- 1
with League.Strings;
with Gela.Grammars.Constructors;

package Ag is

   type Parser is tagged limited private;

   procedure Read
     (Self : in out Parser;
      Text : League.Strings.Universal_String);

   function Grammar (Self : in out Parser) return Gela.Grammars.Grammar;

private

   type Parser is tagged limited record
      Constructor : Gela.Grammars.Constructors.Constructor;
   end record;
-- 2
end Ag;
