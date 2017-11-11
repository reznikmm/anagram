with Ada.Unchecked_Deallocation;
with Ada.Wide_Wide_Text_IO;

package body AST is

   Last : Natural := 0;

   ---------------
   -- Reference --
   ---------------

   procedure Dereference
     (Self   : access Node_Fabric;
      Object : in out Node_Access)
   is
      procedure Free is new
        Ada.Unchecked_Deallocation (AST.Node, AST.Node_Access);
   begin
      if Object.Count = 1 then
         for X of Object.Children loop
            if X /= null then
               Dereference (Self, X);
            end if;
         end loop;

         Free (Object);
      else
         Object.Count := Object.Count - 1;
      end if;
   end Dereference;

   ---------------
   -- Reference --
   ---------------

   procedure Reference
     (Self   : access Node_Fabric;
      Object : Node_Access)
   is
      pragma Unreferenced (Self);
   begin
      Object.Count := Object.Count + 1;
   end Reference;

   ---------------
   -- Set_Child --
   ---------------

   procedure Set_Child
     (Self    : access Node_Fabric;
      Object  : Node_Access;
      Index   : Positive;
      Value   : Node_Access) is
   begin
      Object.Children (Index) := Value;
      Reference (Self, Value);
   end Set_Child;

   ---------------
   -- New_Token --
   ---------------

   function New_Token
     (Self : access Node_Fabric)
      return Node_Access
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

   function New_Node
     (Self       : access Node_Fabric;
      Production : Gela.Grammars.Production_Index)
      return Node_Access
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

   function New_Alternative
     (Self : access Node_Fabric;
      NT   : Gela.Grammars.Non_Terminal_Index)
      return Node_Access
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
