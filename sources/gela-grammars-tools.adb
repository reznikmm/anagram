------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

package body Gela.Grammars.Tools is

   ---------------
   -- Get_First --
   ---------------

   procedure Get_First
     (Input : Grammar;
      Value : out Terminal_Set_Per_Production)
   is
      Ignore : Non_Terminal_Set_Per_Production
        (Input.Last_Non_Terminal, Input.Last_Production);
   begin
      Get_First (Input, Value, Ignore);
   end Get_First;


   ---------------
   -- Get_First --
   ---------------

   procedure Get_First
     (Input    : Grammar;
      Value    : out Terminal_Set_Per_Production;
      Value_NT : out Non_Terminal_Set_Per_Production)
   is
      procedure Set (P : Production_Index; T : Terminal_Count);
      procedure Set (P : Production_Index; NT : Non_Terminal_Index);
      function Accept_Empty_String (NT : Non_Terminal_Index) return Boolean;

      Again : Boolean := True;

      -------------------------
      -- Accept_Empty_String --
      -------------------------

      function Accept_Empty_String
        (NT : Non_Terminal_Index)
            return Boolean
      is
         From : constant Production_Index := Input.Non_Terminal (NT).First;
      begin
         for Production in From .. Input.Non_Terminal (NT).Last loop
            if Value.Map (Production, ε) then
               return True;
            end if;
         end loop;

         return False;
      end Accept_Empty_String;

      ---------
      -- Set --
      ---------

      procedure Set (P : Production_Index; T : Terminal_Count) is
      begin
         if not Value.Map (P, T) then
            Value.Map (P, T) := True;
            Again := True;
         end if;
      end Set;

      ---------
      -- Set --
      ---------

      procedure Set (P : Production_Index; NT : Non_Terminal_Index) is
         First : constant Production_Index := Input.Non_Terminal (NT).First;
      begin
         if not Value_NT.Map (P, NT) then
            Value_NT.Map (P, NT) := True;
            Again := True;
         end if;

         for Production in First .. Input.Non_Terminal (NT).Last loop
            for T in 1 .. Input.Last_Terminal loop
               if not Value.Map (P, T) and Value.Map (Production, T) then
                  Again := True;
                  Value.Map (P, T) := True;
               end if;
            end loop;

            for J in 1 .. Input.Last_Non_Terminal loop
               if not Value_NT.Map (P, J) and Value_NT.Map (Production, J) then
                  Again := True;
                  Value_NT.Map (P, J) := True;
               end if;
            end loop;
         end loop;
      end Set;

   begin
      Value.Map := (others => (others => False));
      Value_NT.Map := (others => (others => False));

      while Again loop
         Again := False;  --  Set will trigger Again if change Value

         for P in Input.Production'Range loop
            declare
               From : constant Part_Index := Input.Production (P).First;
               To   : constant Part_Count := Input.Production (P).Last;
            begin
               if From > To then
                  Set (P, ε);
               end if;

               for Part in From .. To loop
                  if Input.Part (Part).Is_Terminal_Reference then
                     Set (P, T => Input.Part (Part).Denote);
                     exit;
                  else
                     Set (P, NT => Input.Part (Part).Denote);

                     exit when not Accept_Empty_String
                                     (Input.Part (Part).Denote);
                  end if;

                  if Part = To then
                     Set (P, ε);
                  end if;
               end loop;
            end;
         end loop;
      end loop;
   end Get_First;

   ---------------
   -- Get_First --
   ---------------

   procedure Get_First
     (Input : Grammar;
      Value : out Terminal_Set_Per_Non_Terminal)
   is
      Ignore : Non_Terminal_Set_Per_Non_Terminal (Input.Last_Non_Terminal);
   begin
      Get_First (Input, Value, Ignore);
   end Get_First;

   ---------------
   -- Get_First --
   ---------------

   procedure Get_First
     (Input    : Grammar;
      Value    : out Terminal_Set_Per_Non_Terminal;
      Value_NT : out Non_Terminal_Set_Per_Non_Terminal)
   is
      First : Production_Index;
      Temp  : Terminal_Set_Per_Production
        (Input.Last_Terminal, Input.Last_Production);

      Temp_NT : Non_Terminal_Set_Per_Production
        (Input.Last_Non_Terminal, Input.Last_Production);
   begin
      Get_First (Input, Temp, Temp_NT);

      for NT in 1 .. Input.Last_Non_Terminal loop
         First := Input.Non_Terminal (NT).First;

         for T in 0 .. Input.Last_Terminal loop
            Value.Map (NT, T) := False;

            for Production in First .. Input.Non_Terminal (NT).Last loop
               Value.Map (NT, T) :=
                 Value.Map (NT, T) or Temp.Map (Production, T);
            end loop;
         end loop;

         for J in 1 .. Input.Last_Non_Terminal loop
            Value_NT.Map (NT, J) := False;

            for Production in First .. Input.Non_Terminal (NT).Last loop
               Value_NT.Map (NT, J) :=
                 Value_NT.Map (NT, J) or Temp_NT.Map (Production, J);
            end loop;
         end loop;
      end loop;
   end Get_First;

   ----------------
   -- Get_Follow --
   ----------------

   procedure Get_Follow
     (Input : Grammar;
      First : Terminal_Set_Per_Non_Terminal;
      Value : out Terminal_Set_Per_Non_Terminal)
   is
      Dummy  : constant Non_Terminal_Set_Per_Non_Terminal :=
        (Last_Non_Terminal => Input.Last_Non_Terminal,
         Map               => (others => (others => False)));

      Ignore : Non_Terminal_Set_Per_Non_Terminal (Input.Last_Non_Terminal);
   begin
      Get_Follow (Input, First, Dummy, Value, Ignore);
   end Get_Follow;

   ----------------
   -- Get_Follow --
   ----------------

   procedure Get_Follow
     (Input    : Grammar;
      First    : Terminal_Set_Per_Non_Terminal;
      First_NT : Non_Terminal_Set_Per_Non_Terminal;
      Value    : out Terminal_Set_Per_Non_Terminal;
      Value_NT : out Non_Terminal_Set_Per_Non_Terminal)
   is
      procedure Set (NT : Non_Terminal_Index; T : Terminal_Count);

      procedure Set
        (Target  : Non_Terminal_Index;
         Source  : Non_Terminal_Index;
         From    : Terminal_Set_Per_Non_Terminal;
         From_NT : Non_Terminal_Set_Per_Non_Terminal;
         Skip    : Boolean);

      Again   : Boolean := True;
      Is_Last : Boolean;

      ---------
      -- Set --
      ---------

      procedure Set (NT : Non_Terminal_Index; T : Terminal_Count) is
      begin
         if not Value.Map (NT, T) then
            Value.Map (NT, T) := True;
            Again := True;
         end if;
      end Set;

      procedure Set
        (Target  : Non_Terminal_Index;
         Source  : Non_Terminal_Index;
         From    : Terminal_Set_Per_Non_Terminal;
         From_NT : Non_Terminal_Set_Per_Non_Terminal;
         Skip    : Boolean) is
      begin
         for T in Boolean'Pos (Skip) .. Input.Last_Terminal loop
            Value.Map (Target, T) :=
              Value.Map (Target, T) or From.Map (Source, T);
         end loop;

         for NT in 1 .. Input.Last_Non_Terminal loop
            Value_NT.Map (Target, NT) :=
              Value_NT.Map (Target, NT) or From_NT.Map (Source, NT);
         end loop;
      end Set;

      EOF : constant Terminal_Count := 0;
   begin
      Value.Map := (others => (others => False));
      Value_NT.Map := (others => (others => False));

      Value.Map (Input.Root, EOF) := True;

      while Again loop
         Again := False;  --  Set will trigger Again if change Value

         for NT in 1 .. Input.Last_Non_Terminal loop
            for P in
              Production_Index'(Input.Non_Terminal (NT).First)
              ..
                Input.Non_Terminal (NT).Last
            loop
               Is_Last := True;

               for Part in reverse
                 Part_Index'(Input.Production (P).First)
                 ..
                   Input.Production (P).Last
               loop
                  if Input.Part (Part).Is_Non_Terminal_Reference then
                     if Is_Last then
                        Set
                          (Input.Part (Part).Denote,
                           NT,
                           Value,
                           Value_NT,
                           Skip => False);

                        if not First.Map (Input.Part (Part).Denote, ε) then
                           Is_Last := False;
                        end if;
                     end if;

                     if Part = Input.Production (P).Last then
                        null;
                     elsif Input.Part (Part + 1).Is_Terminal_Reference then
                        Set (Input.Part (Part).Denote,
                             Input.Part (Part + 1).Denote);
                     else
                        Set (Input.Part (Part).Denote,
                             Input.Part (Part + 1).Denote,
                             First,
                             First_NT,
                             Skip => True);
                     end if;
                  else
                     Is_Last := False;
                  end if;
               end loop;
            end loop;
         end loop;
      end loop;
   end Get_Follow;

end Gela.Grammars.Tools;
