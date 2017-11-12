--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

--  Rule_Template stores text to evaluate attributes like this:
--
--  ${LHS.Value} := ${Part1.Attr1} + ${Part2.Attr2:1234};

with League.String_Vectors;

package Anagram.Grammars.Rule_Templates is
   pragma Preelaborate;

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

   function Has_Default
     (Self  : Rule_Template;
      Index : Positive) return Boolean;

   function Default
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
      Defs  : League.String_Vectors.Universal_String_Vector;
   end record;

end Anagram.Grammars.Rule_Templates;
