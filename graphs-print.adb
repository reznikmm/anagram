with Ada.Text_IO; use Ada.Text_IO;

procedure Graphs.Print (X : Graph) is
   Empty : Boolean := True;
begin
   for J in 1 .. X.Size loop
      for K in 1 .. X.Size loop
         if Edge (X, J, K) then

            if Empty then
               Put (Node_Index'Image (J) & " ->");
               Empty := False;
            end if;

            Put (Node_Index'Image (K));
         end if;
      end loop;

      if not Empty then
         New_Line;
         Empty := True;
      end if;
   end loop;
end Graphs.Print;
