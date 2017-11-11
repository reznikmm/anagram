--  Check Ordered AG
with Anagram.Grammars.Reader;
with Anagram.Grammars.Ordered;
with Ada.Wide_Wide_Text_IO;

procedure TS_00031 is
   G : constant Anagram.Grammars.Grammar :=
     Anagram.Grammars.Reader.Read ("test.ag");
   Order  : Anagram.Grammars.Ordered.Order_Maps.Map;
   Partitions : Anagram.Grammars.Ordered.Partition_Array (G.Declaration'Range);

   use Anagram.Grammars;


   Found : Boolean;
begin
   Ordered.Find_Order (G, Found, Partitions, Order);

   declare
      use Anagram.Grammars.Ordered.Order_Maps;
      Pos : Cursor := Order.First;
   begin
      while Has_Element (Pos) loop
         declare
            K : constant Ordered.Key := Key (Pos);
            V : constant Ordered.Action := Element (Pos);
            Prod : Production renames G.Production (K.Prod);
         begin
            Ada.Wide_Wide_Text_IO.Put
              (G.Non_Terminal (Prod.Parent).Name.To_Wide_Wide_String);
            Ada.Wide_Wide_Text_IO.Put (".");
            Ada.Wide_Wide_Text_IO.Put (Prod.Name.To_Wide_Wide_String);
            Ada.Wide_Wide_Text_IO.Put (Natural'Wide_Wide_Image (K.Pass));
            case V.Kind is
               when Ordered.Evaluate_Rule =>
                  Ada.Wide_Wide_Text_IO.Put (" eval: ");
                  Ada.Wide_Wide_Text_IO.Put
                    (G.Rule (V.Rule).Text.To_Wide_Wide_String);
               when Ordered.Descent =>
                  Ada.Wide_Wide_Text_IO.Put (" descent: ");
                  Ada.Wide_Wide_Text_IO.Put
                    (G.Part (V.Part).Name.To_Wide_Wide_String);
                  Ada.Wide_Wide_Text_IO.Put
                    (Natural'Wide_Wide_Image (V.Pass));
            end case;

            Ada.Wide_Wide_Text_IO.New_Line;
            Next (Pos);
         end;
      end loop;
   end;

end TS_00031;
