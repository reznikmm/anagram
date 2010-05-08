package Attribute_Grammars.Checks is

   function Is_Well_Formed (AG : Attribute_Grammar) return Boolean;
   --  Root symbol has no inherited attributes
   --  Each production has exactly one rule for each LHS synthesized attribute
   --  and for each RHS symbols' inherited attribute

   function In_Normal_Form (AG : Attribute_Grammar) return Boolean;
   --  No rule uses output attribut as argument

end Attribute_Grammars.Checks;
