------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------
--  Rule_Template stores text to evaluate attributes like this:
--
--  ${LHS.Value} := ${Part1,Attr1} + ${Part2.Attr2};

with League.String_Vectors;

package Gela.Grammars.Rule_Templates is

   type Rule_Template is tagged private;

   function Create
     (Text : S.Universal_String)
     return Rule_Template;

   function Count (Self : Rule_Template) return Natural;
   function Text  (Self : Rule_Template) return S.Universal_String;

   function Part_Name
     (Self  : Rule_Template;
      Index : Positive) return S.Universal_String;

   function Attribute_Name
     (Self  : Rule_Template;
      Index : Positive) return S.Universal_String;

   function Substitute
     (Self  : Rule_Template;
      Values : League.String_Vectors.Universal_String_Vector)
     return S.Universal_String;

private

   type Rule_Template is tagged record
      Text  : S.Universal_String;
      Parts : League.String_Vectors.Universal_String_Vector;
      Attrs : League.String_Vectors.Universal_String_Vector;
   end record;

end Gela.Grammars.Rule_Templates;
