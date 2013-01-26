with Ada.Unchecked_Deallocation;
with Ada.Wide_Wide_Text_IO;

package body AST is

   Last : Natural := 0;

   ---------------
   -- Reference --
   ---------------

   overriding procedure Reference
     (Self : access Node;
      Step : Integer := 1)
   is
      use type Gela.Grammars.AST_Nodes.Node_Access;

      procedure Free is new
        Ada.Unchecked_Deallocation
          (Gela.Grammars.AST_Nodes.Node'Class,
           Gela.Grammars.AST_Nodes.Node_Access);

      Save : Gela.Grammars.AST_Nodes.Node_Access :=
        Gela.Grammars.AST_Nodes.Node_Access (Self);
   begin
      if Self.Count = 1 and Step = -1 then
         for X of Self.Children loop
            if X /= null then
               X.Reference (-1);
            end if;
         end loop;

         Free (Save);
      else
         Self.Count := Self.Count + Step;
      end if;
   end Reference;

   ---------------
   -- Set_Child --
   ---------------

   overriding procedure Set_Child
     (Self  : in out Node;
      Index : Positive;
      Value : access Gela.Grammars.AST_Nodes.Node'Class) is
   begin
      Self.Children (Index) := Gela.Grammars.AST_Nodes.Node_Access (Value);
      Value.Reference;
   end Set_Child;

   ---------------
   -- New_Token --
   ---------------

   overriding function New_Token
     (Self : Node_Fabric)
      return Gela.Grammars.AST_Nodes.Node_Access
   is
      pragma Unreferenced (Self);
   begin
      Last := Last + 1;
      return new Node'(Identifier     => Last,
                       Is_Token       => True,
                       Is_Alternative => False,
                       Count          => 1,
                       others         => <>);
   end New_Token;

   --------------
   -- New_Node --
   --------------

   overriding function New_Node
     (Self       : Node_Fabric;
      Production : Gela.Grammars.Production_Index)
      return Gela.Grammars.AST_Nodes.Node_Access
   is
      pragma Unreferenced (Self);
   begin
      Last := Last + 1;
      return new Node'(Identifier     => Last,
                       Is_Token       => False,
                       Is_Alternative => False,
                       Prod           => Production,
                       Count          => 1,
                       others         => <>);
   end New_Node;

   ---------------------
   -- New_Alternative --
   ---------------------

   overriding function New_Alternative
     (Self : Node_Fabric;
      NT   : Gela.Grammars.Non_Terminal_Index)
      return Gela.Grammars.AST_Nodes.Node_Access
   is
      pragma Unreferenced (Self);
   begin
      Last := Last + 1;
      return new Node'(Identifier     => Last,
                       Is_Token       => False,
                       Is_Alternative => True,
                       NT             => NT,
                       Count          => 1,
                       others         => <>);
   end New_Alternative;

   -----------
   -- Print --
   -----------

   procedure Print (Self : Node; Input : Gela.Grammars.Grammar) is
   begin
      Ada.Wide_Wide_Text_IO.Put (Integer'Wide_Wide_Image (Self.Identifier));
      if Self.Is_Token then
         Ada.Wide_Wide_Text_IO.Put (" token");
      elsif Self.Is_Alternative then
         Ada.Wide_Wide_Text_IO.Put
           (" alternative " &
              Input.Non_Terminal (Self.NT).Name.To_Wide_Wide_String);
      else
         Ada.Wide_Wide_Text_IO.Put
           (" node " &
              Input.Production (Self.Prod).Name.To_Wide_Wide_String);
      end if;
   end Print;
end AST;
