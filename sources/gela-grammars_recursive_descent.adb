------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--        Library for dealing with grammars for for Gela project,           --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------

with League.Strings;
with League.String_Vectors;
with Ada.Wide_Wide_Text_IO;
with Gela.Grammars.Rule_Templates;
with Gela.Grammars_Checks;

package body Gela.Grammars_Recursive_Descent is

   use Gela.Grammars;

   procedure Generate
     (Self : Grammar;
      File : String;
      Ok   : out Boolean)
   is

      ε : constant Terminal_Count := 0;

      EOF : constant Terminal_Count := 0;

      type Terminal_Set is array (ε .. Self.Last_Terminal) of Boolean;
      pragma Pack (Terminal_Set);

      Empty : constant Terminal_Set := (others => False);

      type Terminal_Set_Per_Production is
        array (1 .. Self.Last_Production) of Terminal_Set;

      type Terminal_Set_Per_NT is
        array (1 .. Self.Last_Non_Terminal) of Terminal_Set;

      procedure Get_First (Value  : out Terminal_Set_Per_Production);

      procedure Get_Follow
        (First  : Terminal_Set_Per_NT;
         Value  : out Terminal_Set_Per_NT);

      procedure To_NT_First
        (Value  : Terminal_Set_Per_Production;
         Result : out Terminal_Set_Per_NT);

      procedure Check_LL_1
        (First   : Terminal_Set_Per_Production;
         Follow  : Terminal_Set_Per_NT;
         Verbose : Boolean;
         Ok      : out Boolean);

      procedure Check_Left_Recursion
        (First   : Terminal_Set_Per_NT;
         Verbose : Boolean;
         Ok      : out Boolean);

      procedure P (Text : Wide_Wide_String);
      procedure Print_Conflict (Conflict : Terminal_Set);

      procedure Generate_Tokens;
      procedure Generate_Specs;
      procedure Generate_Body (First : Terminal_Set_Per_Production);
      procedure Generate_Cases (Set : Terminal_Set);
      procedure Generate_Productions
        (First : Terminal_Set_Per_Production;
         From  : Production_Index;
         To    : Production_Count);
      procedure Generate_Production
        (Prefix   : Wide_Wide_String;
         Prod     : Production_Index;
         From, To : Part_Count);

      procedure Generate_Spec
        (NT : Non_Terminal_Index;
         Suffix : Wide_Wide_String);

      procedure Generate_Vars
        (Prefix   : Wide_Wide_String;
         Name     : Wide_Wide_String;
         From     : Attribute_Declaration_Index;
         To       : Attribute_Declaration_Count);

      procedure Generate_Call
        (Prefix   : Wide_Wide_String;
         Name     : Wide_Wide_String;
         Denote   : Wide_Wide_String;
         From     : Attribute_Declaration_Index;
         To       : Attribute_Declaration_Count);

      procedure Generate_Rules
        (Prefix   : Wide_Wide_String;
         Part     : Part_Count;
         From, To : Rule_Count);

      function In_Out
        (Decl : Attribute_Declaration_Index)
        return Wide_Wide_String;

      function Make_Args
        (Self : Rule_Templates.Rule_Template)
        return League.String_Vectors.Universal_String_Vector;

      function Open_File return Ada.Wide_Wide_Text_IO.File_Type;

      ---------------
      -- Open_File --
      ---------------

      function Open_File return Ada.Wide_Wide_Text_IO.File_Type is
      begin
         if File = "-" then
            return Ada.Wide_Wide_Text_IO.Standard_Output;
         else
            return Result : Ada.Wide_Wide_Text_IO.File_Type do
               Ada.Wide_Wide_Text_IO.Create (Result, Name => File);
            end return;
         end if;
      end Open_File;

      Output : constant Ada.Wide_Wide_Text_IO.File_Type := Open_File;

      --------------------------
      -- Check_Left_Recursion --
      --------------------------

      procedure Check_Left_Recursion
        (First   : Terminal_Set_Per_NT;
         Verbose : Boolean;
         Ok      : out Boolean)
      is
         procedure Check
           (NT   : Non_Terminal_Index;
            From : Part_Index;
            To   : Part_Count);

         procedure Add
           (Target : Non_Terminal_Index;
            Item   : Non_Terminal_Index);

         type Non_Terminal_Set is array (1 .. Self.Last_Non_Terminal)
           of Boolean;
         pragma Pack (Non_Terminal_Set);

         procedure Add
           (Target : Non_Terminal_Index;
            Items  : Non_Terminal_Set);

         Empty : constant Non_Terminal_Set := (others => False);

         type Non_Terminal_Set_Per_NT is
           array (1 .. Self.Last_Non_Terminal) of Non_Terminal_Set;

         Again : Boolean := True;
         Start : Non_Terminal_Set_Per_NT := (others => Empty);

         ---------
         -- Add --
         ---------

         procedure Add
           (Target : Non_Terminal_Index;
            Item   : Non_Terminal_Index) is
         begin
            if not Start (Target) (Item) then
               Start (Target) (Item) := True;
               Again := True;
            end if;
         end Add;

         ---------
         -- Add --
         ---------

         procedure Add
           (Target : Non_Terminal_Index;
            Items  : Non_Terminal_Set)
         is
            Old : constant Non_Terminal_Set := Start (Target);
         begin
            Start (Target) := Start (Target) or Items;

            if Start (Target) /= Old then
               Again := True;
            end if;
         end Add;

         -----------
         -- Check --
         -----------

         procedure Check
           (NT   : Non_Terminal_Index;
            From : Part_Index;
            To   : Part_Count) is
         begin
            for J in From .. To loop
               if Self.Part (J).Is_Terminal_Reference then
                  return;
               end if;

               declare
                  Ref : constant Non_Terminal_Index := Self.Part (J).Denote;
               begin
                  Add (NT, Ref);
                  Add (NT, Start (Ref));

                  if not First (Ref) (ε) then
                     return;
                  end if;
               end;
            end loop;
         end Check;

         From  : Production_Index;
      begin
         while Again loop
            Again := False;  --  Check will trigger Again if Start changed

            for NT in Start'Range loop
               From := Self.Non_Terminal (NT).First;

               for P in From .. Self.Non_Terminal (NT).Last loop
                  Check
                    (NT,
                     Self.Production (P).First,
                     Self.Production (P).Last);
               end loop;
            end loop;
         end loop;

         Ok := True;

         for J in Start'Range loop
            if Start (J) (J) then
               Ok := False;

               if Verbose then
                  Ada.Wide_Wide_Text_IO.Put_Line
                    ("Left recursion on non-terminal " &
                       Self.Non_Terminal (J).Name.To_Wide_Wide_String);
               end if;
            end if;
         end loop;
      end Check_Left_Recursion;

      ----------------
      -- Check_LL_1 --
      ----------------

      procedure Check_LL_1
        (First   : Terminal_Set_Per_Production;
         Follow  : Terminal_Set_Per_NT;
         Verbose : Boolean;
         Ok      : out Boolean)
      is
         Index : Production_Count;
         From  : Production_Index;
      begin
         Ok := True;

         for NT in 1 .. Self.Last_Non_Terminal loop
            Index := 0;

            From := Self.Non_Terminal (NT).First;

            for P in From .. Self.Non_Terminal (NT).Last loop
               for J in From .. P - 1 loop
                  if (First (P) and First (J)) /= Empty then
                     if Verbose then
                        Ada.Wide_Wide_Text_IO.Put_Line
                          ("LL(1) conflict on non-terminal " &
                             Self.Non_Terminal (NT).Name.To_Wide_Wide_String &
                             " between productions " &
                             Self.Production (P).Name.To_Wide_Wide_String &
                             " and " &
                             Self.Production (J).Name.To_Wide_Wide_String &
                             " on : ");

                        Print_Conflict (First (P) and First (J));
                     end if;

                     Ok := False;
                  end if;
               end loop;

               if First (P) (ε) then
                  Index := P;
               end if;
            end loop;

            if Index /= 0 then
               for P in From .. Self.Non_Terminal (NT).Last loop
                  if P /= Index and (First (P) and Follow (NT)) /= Empty then
                     Ok := False;

                     if Verbose then
                        Ada.Wide_Wide_Text_IO.Put_Line
                          ("LL(1) conflict on non-terminal " &
                             Self.Non_Terminal (NT).Name.To_Wide_Wide_String &
                             " in production " &
                             Self.Production (P).Name.To_Wide_Wide_String &
                             " and empty " &
                             Self.Production (Index).Name.To_Wide_Wide_String &
                             " on : ");

                        Print_Conflict (First (P) and Follow (NT));
                     end if;
                  end if;
               end loop;
            end if;
         end loop;
      end Check_LL_1;

      -------------------
      -- Generate_Body --
      -------------------

      procedure Generate_Body (First : Terminal_Set_Per_Production) is
      begin
         P ("with Tokens; use Tokens;");
         P ("package body Aaa is");

         for NT in 1 .. Self.Last_Non_Terminal loop
            Generate_Spec (NT, " is");
            P ("   begin");

            Generate_Productions
              (First,
               Self.Non_Terminal (NT).First,
               Self.Non_Terminal (NT).Last);

            P ("   end " & Self.Non_Terminal (NT).Name.To_Wide_Wide_String &
                 ";");
            P ("");
         end loop;

         P ("");
         P ("end Aaa;");
      end Generate_Body;

      -------------------
      -- Generate_Call --
      -------------------

      procedure Generate_Call
        (Prefix   : Wide_Wide_String;
         Name     : Wide_Wide_String;
         Denote   : Wide_Wide_String;
         From     : Attribute_Declaration_Index;
         To       : Attribute_Declaration_Count)
      is
         use League.Strings;
         Args : Universal_String;
      begin
         if From > To then
            P (Prefix & "   Self." & Denote & ";");
            return;
         end if;

         for J in From .. To loop
            Args.Append (Name);
            Args.Append (".");
            Args.Append (Self.Declaration (J).Name);

            if J /= To then
               Args.Append (", ");
            end if;
         end loop;

         P (Prefix & "   Self." & Denote & " (" &
              Args.To_Wide_Wide_String & ");");
      end Generate_Call;

      --------------------
      -- Generate_Cases --
      --------------------

      procedure Generate_Cases (Set : Terminal_Set) is
         First : Boolean := True;
         Last : Terminal_Index;
      begin
         for T in reverse 1 .. Set'Last loop
            if Set (T) then
               Last := T;
               exit;
            end if;
         end loop;

         for T in 1 .. Set'Last loop
            if Set (T) then
               if First and Last = T then
                  P ("         when " &
                       Self.Terminal (T).Image.To_Wide_Wide_String &
                       " =>");
               elsif First then
                  P ("         when " &
                       Self.Terminal (T).Image.To_Wide_Wide_String &
                       " |");
               elsif Last = T then
                  P ("           " &
                       Self.Terminal (T).Image.To_Wide_Wide_String & " =>");
               else
                  P ("           " &
                       Self.Terminal (T).Image.To_Wide_Wide_String & " |");
               end if;

               First := False;
            end if;
         end loop;
      end Generate_Cases;

      -------------------------
      -- Generate_Production --
      -------------------------

      procedure Generate_Production
        (Prefix   : Wide_Wide_String;
         Prod     : Production_Index;
         From, To : Part_Count) is
      begin
         P (Prefix & "declare");

         for J in From .. To loop
            if Self.Part (J).Is_Terminal_Reference then
               Generate_Vars
                 (Prefix & "   ",
                  Self.Part (J).Name.To_Wide_Wide_String,
                  Self.Terminal (Self.Part (J).Denote).First_Attribute,
                  Self.Terminal (Self.Part (J).Denote).Last_Attribute);
            else
               Generate_Vars
                 (Prefix & "   ",
                  Self.Part (J).Name.To_Wide_Wide_String,
                  Self.Non_Terminal (Self.Part (J).Denote).First_Attribute,
                  Self.Non_Terminal (Self.Part (J).Denote).Last_Attribute);
            end if;
         end loop;

         P (Prefix & "begin");

         for J in From .. To loop
            if Self.Part (J).Is_Terminal_Reference then
               Generate_Rules
                 (Prefix & "   ",
                  J,
                  Self.Production (Prod).First_Rule,
                  Self.Production (Prod).Last_Rule);

               P (Prefix & "   Self.Match (Tokens." &
                    Self.Terminal (Self.Part (J).Denote).Image.
                      To_Wide_Wide_String &
                    ");");
            else
               Generate_Rules
                 (Prefix & "   ",
                  J,
                  Self.Production (Prod).First_Rule,
                  Self.Production (Prod).Last_Rule);

               Generate_Call
                 (Prefix,
                  Self.Part (J).Name.To_Wide_Wide_String,
                  Self.Non_Terminal (Self.Part (J).Denote).Name.
                      To_Wide_Wide_String,
                  Self.Non_Terminal (Self.Part (J).Denote).First_Attribute,
                  Self.Non_Terminal (Self.Part (J).Denote).Last_Attribute);
            end if;
         end loop;

         Generate_Rules
           (Prefix & "   ",
            0,
            Self.Production (Prod).First_Rule,
            Self.Production (Prod).Last_Rule);

         if From > To then
            P (Prefix & "   null;");
         end if;
         P (Prefix & "end;");
      end Generate_Production;

      --------------------------
      -- Generate_Productions --
      --------------------------

      procedure Generate_Productions
        (First : Terminal_Set_Per_Production;
         From  : Production_Index;
         To    : Production_Count)
      is
         Others_Index : Production_Count := 0;
      begin
         if From = To then
            Generate_Production
              ("      ",
               From,
               Self.Production (From).First,
               Self.Production (From).Last);
            return;
         end if;

         P ("      case Self.The_Token is");

         for Prod in From .. To loop
            if First (Prod) (ε) then
               Others_Index := Prod;
            else
               Generate_Cases (First (Prod));

               Generate_Production
                 ("            ",
                  Prod,
                  Self.Production (Prod).First,
                  Self.Production (Prod).Last);
            end if;
         end loop;

         P ("         when others =>");

         if Others_Index = 0 then
            P ("            Self.Syntax_Error;");
         else
            Generate_Production
              ("            ",
               Others_Index,
               Self.Production (Others_Index).First,
               Self.Production (Others_Index).Last);
         end if;

         P ("      end case;");
      end Generate_Productions;

      --------------------
      -- Generate_Rules --
      --------------------

      procedure Generate_Rules
        (Prefix   : Wide_Wide_String;
         Part     : Part_Count;
         From, To : Rule_Count)
      is
         use Gela.Grammars.Rule_Templates;
         --         Index : Attribute_Declaration_Index;
      begin
         for J in From .. To loop
            if Self.Attribute (Self.Rule (J).Result).Origin = Part then
               declare
                  Template : constant Rule_Template :=
                    Create (Self.Rule (J).Text);
               begin
                  P (Prefix & Template.Substitute
                     (Make_Args (Template)).To_Wide_Wide_String);
               end;
            end if;
         end loop;
      end Generate_Rules;

      --------------------
      -- Generate_Specs --
      --------------------

      procedure Generate_Specs is
      begin
         P ("with Tokenizers;");

         if not Self.With_List.Is_Empty then
            P ("with " & Self.With_List.To_Wide_Wide_String & ";");
         end if;

         P ("package Aaa is");
         P ("");
         P ("   type Parser is new Tokenizers.Tokenizer with null record;");
         P ("");

         for J in 1 .. Self.Last_Non_Terminal loop
            Generate_Spec (J, ";");
            P ("");
         end loop;

         P ("end Aaa;");
      end Generate_Specs;

      -------------------
      -- Generate_Spec --
      -------------------

      procedure Generate_Spec
        (NT : Non_Terminal_Index;
         Suffix : Wide_Wide_String)
      is
         From : constant Attribute_Declaration_Index :=
           Self.Non_Terminal (NT).First_Attribute;
         To   : constant Attribute_Declaration_Count :=
           Self.Non_Terminal (NT).Last_Attribute;
      begin
         P ("   procedure " & Self.Non_Terminal (NT).Name.To_Wide_Wide_String);

         if From > To then
            P ("     (Self : in out Parser)" & Suffix);
            return;
         end if;

         P ("     (Self : in out Parser;");

         for J in From .. To loop
            if J = To then
               P ("      " & Self.Declaration (J).Name.To_Wide_Wide_String &
                    " : " & In_Out (J) &
                    Self.Declaration (J).Type_Name.To_Wide_Wide_String &
                    ")" & Suffix);
            else
               P ("      " & Self.Declaration (J).Name.To_Wide_Wide_String &
                    " : " & In_Out (J) &
                    Self.Declaration (J).Type_Name.To_Wide_Wide_String &
                    ";");
            end if;
         end loop;
      end Generate_Spec;

      ---------------------
      -- Generate_Tokens --
      ---------------------

      procedure Generate_Tokens is
      begin
         P ("package Tokens is");
         P ("");
         P ("   type Token is");

         for T in 1 .. Self.Last_Terminal loop
            if T = 1 then
               P ("     (" &
                    Self.Terminal (T).Image.To_Wide_Wide_String & ",");
            elsif T = Self.Last_Terminal then
               P ("      " &
                    Self.Terminal (T).Image.To_Wide_Wide_String & ");");
            else
               P ("      " &
                    Self.Terminal (T).Image.To_Wide_Wide_String & ",");
            end if;
         end loop;

         P ("");
         P ("end Tokens;");
         P ("");
      end Generate_Tokens;

      -------------------
      -- Generate_Vars --
      -------------------

      procedure Generate_Vars
        (Prefix   : Wide_Wide_String;
         Name     : Wide_Wide_String;
         From     : Attribute_Declaration_Index;
         To       : Attribute_Declaration_Count) is
      begin
         if From > To then
            return;
         end if;

         P (Prefix & "package " & Name & " is");

         for J in From .. To loop
            P (Prefix & "   " & Self.Declaration (J).Name.To_Wide_Wide_String &
                 " : " &
                 Self.Declaration (J).Type_Name.To_Wide_Wide_String &
                 ";");
         end loop;

         P (Prefix & "end " & Name & ";");
         P ("");
      end Generate_Vars;

      ----------------
      -- Get_First --
      ----------------

      procedure Get_First (Value  : out Terminal_Set_Per_Production) is
         procedure Set (P : Production_Index; T : Terminal_Count);
         procedure Set (NT : Non_Terminal_Index; Target : Production_Index);
         function Accept_Empty_String (NT : Non_Terminal_Index) return Boolean;

         Again : Boolean := True;

         -------------------------
         -- Accept_Empty_String --
         -------------------------

         function Accept_Empty_String
           (NT : Non_Terminal_Index)
           return Boolean
         is
            From : constant Production_Index := Self.Non_Terminal (NT).First;
         begin
            for Production in From .. Self.Non_Terminal (NT).Last loop
               if Value (Production) (ε) then
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
            if not Value (P) (T) then
               Value (P) (T) := True;
               Again := True;
            end if;
         end Set;

         ---------
         -- Set --
         ---------

         procedure Set (NT : Non_Terminal_Index; Target : Production_Index) is
            Old  : constant Terminal_Set := Value (Target);
            From : constant Production_Index := Self.Non_Terminal (NT).First;
         begin
            for Production in From .. Self.Non_Terminal (NT).Last loop
               Value (Target) (1 .. Self.Last_Terminal) :=
                 Value (Target) (1 .. Self.Last_Terminal)
                 or
                 Value (Production) (1 .. Self.Last_Terminal);
            end loop;

            if Value (Target) /= Old then
               Again := True;
            end if;
         end Set;

      begin
         Value := (others => Empty);

         while Again loop
            Again := False;  --  Set will trigger Again if change Value

            for P in Self.Production'Range loop
               declare
                  From : constant Part_Index := Self.Production (P).First;
                  To   : constant Part_Count := Self.Production (P).Last;
               begin
                  if From > To then
                     Set (P, ε);
                  end if;

                  for Part in
                    From .. To
                  loop
                     if Self.Part (Part).Is_Terminal_Reference then
                        Set (P, Self.Part (Part).Denote);
                        exit;
                     else
                        Set (Self.Part (Part).Denote, P);

                        exit when
                          not Accept_Empty_String (Self.Part (Part).Denote);
                     end if;

                     if Part = To then
                        Set (P, ε);
                     end if;
                  end loop;
               end;
            end loop;
         end loop;
      end Get_First;

      ----------------
      -- Get_Follow --
      ----------------

      procedure Get_Follow
        (First  : Terminal_Set_Per_NT;
         Value  : out Terminal_Set_Per_NT)
      is
         procedure Set (NT : Non_Terminal_Index; T : Terminal_Count);

         procedure Set
           (Result : in out Terminal_Set;
            Value  : Terminal_Set;
            Skip   : Boolean);

         Again   : Boolean := True;
         Is_Last : Boolean;

         ---------
         -- Set --
         ---------

         procedure Set (NT : Non_Terminal_Index; T : Terminal_Count) is
         begin
            if not Value (NT) (T) then
               Value (NT) (T) := True;
               Again := True;
            end if;
         end Set;

         procedure Set
           (Result : in out Terminal_Set;
            Value  : Terminal_Set;
            Skip   : Boolean) is
         begin
            if Skip then
               Result (1 .. Result'Last) := Result (1 .. Result'Last)
                 or Value (1 .. Result'Last);
            else
               Result := Result or Value;
            end if;
         end Set;

      begin
         Value := (others => Empty);

         Value (Self.Root) (EOF) := True;

         while Again loop
            Again := False;  --  Set will trigger Again if change Value

            for NT in 1 .. Self.Last_Non_Terminal loop
               for P in
                 Production_Index'(Self.Non_Terminal (NT).First)
                 ..
                 Self.Non_Terminal (NT).Last
               loop
                  Is_Last := True;

                  for Part in reverse
                    Part_Index'(Self.Production (P).First)
                    ..
                    Self.Production (P).Last
                  loop
                     if Self.Part (Part).Is_Non_Terminal_Reference then
                        if Is_Last then
                           Set
                             (Value (Self.Part (Part).Denote),
                              Value (NT),
                              Skip => False);

                           if not First (Self.Part (Part).Denote) (ε) then
                              Is_Last := False;
                           end if;
                        end if;

                        if Part = Self.Production (P).Last then
                           null;
                        elsif Self.Part (Part + 1).Is_Terminal_Reference then
                           Set (Self.Part (Part).Denote,
                                Self.Part (Part + 1).Denote);
                        else
                           Set (Value (Self.Part (Part).Denote),
                                First (Self.Part (Part + 1).Denote),
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

      ------------
      -- In_Out --
      ------------

      function In_Out
        (Decl : Attribute_Declaration_Index)
        return Wide_Wide_String is
      begin
         if Self.Declaration (Decl).Is_Inherited then
            return "";
         else
            return "in out ";
         end if;
      end In_Out;

      ---------------
      -- Make_Args --
      ---------------

      function Make_Args
        (Self : Rule_Templates.Rule_Template)
        return League.String_Vectors.Universal_String_Vector
      is
         use type League.Strings.Universal_String;
         Item   : League.Strings.Universal_String;
         Result : League.String_Vectors.Universal_String_Vector;
      begin
         for J in 1 .. Self.Count loop
            Item := Self.Part_Name (J) & "." & Self.Attribute_Name (J);
            Result.Append (Item);
         end loop;

         return Result;
      end Make_Args;

      -------
      -- P --
      -------

      procedure P (Text : Wide_Wide_String) is
      begin
         Ada.Wide_Wide_Text_IO.Put_Line (Output, Text);
      end P;

      --------------------
      -- Print_Conflict --
      --------------------

      procedure Print_Conflict (Conflict : Terminal_Set) is
      begin
         for J in Conflict'Range loop
            if Conflict (J) then
               Ada.Wide_Wide_Text_IO.Put (" ");

               if J = ε then
                  Ada.Wide_Wide_Text_IO.Put ("<empty string>");
               else
                  Ada.Wide_Wide_Text_IO.Put
                    (Self.Terminal (J).Image.To_Wide_Wide_String);
               end if;
            end if;
         end loop;

         Ada.Wide_Wide_Text_IO.New_Line;
      end Print_Conflict;

      -----------------
      -- To_NT_First --
      -----------------

      procedure To_NT_First
        (Value  : Terminal_Set_Per_Production;
         Result : out Terminal_Set_Per_NT)
      is
         From : Production_Index;
      begin
         for NT in 1 .. Self.Last_Non_Terminal loop
            From := Self.Non_Terminal (NT).First;
            Result (NT) := Value (From);

            for Production in From + 1 .. Self.Non_Terminal (NT).Last loop
               Result (NT) := Result (NT) or Value (Production);
            end loop;
         end loop;
      end To_NT_First;

      Value  : Terminal_Set_Per_Production;
      First  : Terminal_Set_Per_NT;
      Follow : Terminal_Set_Per_NT;
   begin
      if not Gela.Grammars_Checks.Is_Well_Formed (Self, Verbose => True) then
         Ok := False;
         return;
      elsif not Gela.Grammars_Checks.Is_L_Attributed (Self) then
         Ok := False;
         return;
      end if;

      Get_First (Value);
      To_NT_First (Value, First);
      Get_Follow (First, Follow);

      Check_Left_Recursion (First, Verbose => True, Ok => Ok);

      if Ok then
         Check_LL_1 (Value, Follow, Verbose => True, Ok => Ok);

         if Ok then
            Generate_Tokens;
            Generate_Specs;
            Generate_Body (Value);
         end if;
      end if;
   end Generate;

end Gela.Grammars_Recursive_Descent;
