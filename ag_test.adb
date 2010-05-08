with Ada.Text_IO;

--with Attribute_Grammars.Example;
with Attribute_Grammars.Print;
with Attribute_Grammars.Internal;

with Attribute_Grammars.Read_XML;
--with Attribute_Grammars.Generate;
with Attribute_Grammars.Generate_ORE;
with Attribute_Grammars.Checks;
with Attribute_Grammars.Ordered;

with Graphs.Print;

procedure AG_Test is
   use Attribute_Grammars;

begin
   declare
      AG : Attribute_Grammar;
   begin
      Read_XML.Read ("aaa.xml", AG);
      --      Generate (AG);
      Ada.Text_IO.Put_Line
        ("--Is_Well_Formed " & Boolean'Image (Checks.Is_Well_Formed (AG)));

      Ada.Text_IO.Put_Line
        ("--In_Normal_Form " & Boolean'Image (Checks.In_Normal_Form (AG)));

      Ada.Text_IO.Put_Line
        ("--Is_Ordered " & Boolean'Image (Ordered.Is_Ordered (AG)));
   end;
end AG_Test;
