package body Graphs is
   use Interfaces;

   function "+" (X : Boolean) return Unsigned;
   pragma Inline ("+");

   ---------
   -- "+" --
   ---------

   function "+" (X : Boolean) return Unsigned is
      Result : constant array (Boolean) of Unsigned := (0, -1);
   begin
      return Result (X);
   end "+";

   ---------
   -- Add --
   ---------

   procedure Add
     (Left  : in out Graph;
      Right : Graph;
      Shift : Node_Count := 0) is
   begin
      if Right.Size + Shift > Left.Size then
         raise Constraint_Error;
      end if;

      for J in 1 .. Right.Size loop
         Left.X (J + Shift) := Left.X (J + Shift) or
           Shift_Left (Right.X (J), Natural (Shift));
      end loop;
   end Add;

   ------------------
   -- Add_Subgraph --
   ------------------

   procedure Add_Subgraph
     (Left  : in out Graph;
      Right : Graph)
   is
      Mask : constant Unsigned := Shift_Left (1, Natural (Left.Size)) - 1;
   begin
      if Left.Size > Right.Size then
         raise Constraint_Error;
      end if;

      for J in 1 .. Left.Size loop
         Left.X (J) := Left.X (J) or (Right.X (J) and Mask);
      end loop;
   end Add_Subgraph;

   ------------------
   -- Add_Subgraph --
   ------------------

   procedure Add_Subgraph
     (Left    : in out Graph;
      Right   : Graph;
      Changed : in out Boolean;
      Shift   : Node_Count := 0)
   is
      Sum  : Unsigned := 0;
      Temp : Unsigned;
      Mask : constant Unsigned := Shift_Left (1, Natural (Left.Size)) - 1;
   begin
      if Left.Size + Shift > Right.Size then
         raise Constraint_Error;
      end if;

      for J in 1 .. Left.Size loop
         Temp := Shift_Right (Right.X (J + Shift), Natural (Shift)) and Mask;
         Sum := Sum or (Temp and not Left.X (J));
         Left.X (J) := Left.X (J) or Temp;
      end loop;

      Changed := Changed or (Sum /= 0);
   end Add_Subgraph;

   ----------
   -- Edge --
   ----------

   function Edge (Self : Graph; A, B : Node_Index) return Boolean is
   begin
      return (Self.X (A) and Shift_Left (1, Natural (B - 1))) /= 0;
   end Edge;

   -------------------------
   -- Difference_Is_Empty --
   -------------------------

   function Difference_Is_Empty (X, Y : Graph) return Boolean is
   begin
      for J in 1 .. Node_Count'Min (X.Size, Y.Size) loop
         if ((not X.X (J)) and Y.X (J)) /= 0 then
            return False;
         end if;
      end loop;

      return True;
   end Difference_Is_Empty;

   ---------------------
   -- Has_Self_Cycles --
   ---------------------

   function Has_Self_Cycles (X : Graph) return Boolean is
      Mask : Unsigned := 1;
   begin
      for J in 1 .. X.Size loop
         if (X.X (J) and Mask) /= 0 then
            return True;
         end if;

         Mask := Mask + Mask;
      end loop;

      return False;
   end Has_Self_Cycles;

   ---------------
   -- Intersect --
   ---------------

   function Intersect (X, Y : Graph) return Boolean is
   begin
      for J in 1 .. Node_Count'Min (X.Size, Y.Size) loop
         if (X.X (J) and Y.X (J)) /= 0 then
            return True;
         end if;
      end loop;

      return False;
   end Intersect;

   --------------
   -- Is_Empty --
   --------------

   function Is_Empty (X : Unsigned) return Boolean is
   begin
      return X = 0;
   end Is_Empty;

   ------------------
   -- Path_Closure --
   ------------------

   procedure Path_Closure (X : in out Graph) is
   begin
      for K in 1 .. X.Size loop
         for I in 1 .. X.Size loop
            X.X (I) := X.X (I) or (+Edge (X, I, K) and X.X (K));
         end loop;
      end loop;
   end Path_Closure;

   --------------
   -- Set_Edge --
   --------------

   procedure Set_Edge
     (Self  : in out Graph;
      A, B  : Node_Index;
      Value : Boolean := True)
   is
   begin
      if Value then
         Self.X (A) := Self.X (A) or Shift_Left (1, Natural (B - 1));
      else
         Self.X (A) := Self.X (A) and not Shift_Left (1, Natural (B - 1));
      end if;
   end Set_Edge;

end Graphs;
