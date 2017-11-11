--  Check local attributes in Ordered AG
with Gela.Grammars.Reader;
with Gela.Grammars.Ordered;
with Gela.Grammars_Checks;
with Ada.Wide_Wide_Text_IO;

procedure TS_00033 is
   G : constant Gela.Grammars.Grammar :=
     Gela.Grammars.Reader.Read ("test.ag");
   Order  : Gela.Grammars.Ordered.Order_Maps.Map;
   Partitions : Gela.Grammars.Ordered.Partition_Array (G.Declaration'Range);

   use Gela.Grammars;

   Found : Boolean;
begin
   if not Gela.Grammars_Checks.Is_Well_Formed (G, True) then
      raise Constraint_Error;
   end if;

   Ordered.Find_Order (G, Found, Partitions, Order);

   declare
      use Gela.Grammars.Ordered.Order_Maps;
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

end TS_00033;
