--  Check extended attributed grammar constructor and debuger output

with Anagram.Grammars_Debug;
with Anagram.Grammars;
with Anagram.Grammars.Constructors;
with League.Strings;

--  NT2 := /P2/ { /PL1/ T3 }
--  NT1 := /P1/ [ /OP1/ T2 NT1 ]

procedure TS_00005 is
   use Anagram.Grammars.Constructors;
   C : Anagram.Grammars.Constructors.Constructor;
begin
   C.Create_Terminal (League.Strings.To_Universal_String ("T2"));
   C.Create_Terminal (League.Strings.To_Universal_String ("T1"));
   C.Create_Terminal (League.Strings.To_Universal_String ("T3"));

   declare
      L1 : constant Part := C.Create_List_Reference
        (League.Strings.To_Universal_String ("L1"),
         League.Strings.To_Universal_String ("L1"));

      P2 : Production := C.Create_Production
        (League.Strings.To_Universal_String ("P2"));

      PL : Production_List := C.Create_Production_List;
   begin
      P2.Add (L1);
      PL.Add (P2);
      C.Create_Non_Terminal (League.Strings.To_Universal_String ("NT2"), PL);
   end;

   declare
      T3 : constant Part := C.Create_Terminal_Reference
        (League.Strings.To_Universal_String ("t3"),
         League.Strings.To_Universal_String ("T3"));

      PL1 : Production := C.Create_Production
        (League.Strings.To_Universal_String ("PL1"));

      PL : Production_List := C.Create_Production_List;
   begin
      PL1.Add (T3);
      PL.Add (PL1);
      C.Create_List (League.Strings.To_Universal_String ("L1"), PL);
   end;

   declare
      T2 : constant Part := C.Create_Terminal_Reference
        (League.Strings.To_Universal_String ("t2"),
         League.Strings.To_Universal_String ("T2"));

      NT2 : constant Part := C.Create_Non_Terminal_Reference
        (League.Strings.To_Universal_String ("nt2"),
         League.Strings.To_Universal_String ("NT2"));

      OP1 : Production := C.Create_Production
        (League.Strings.To_Universal_String ("OP1"));

      P1 : Production := C.Create_Production
        (League.Strings.To_Universal_String ("P1"));

      PL : Production_List := C.Create_Production_List;
   begin
      OP1.Add (T2);
      OP1.Add (NT2);
      PL.Add (OP1);
      P1.Add (C.Create_Option (League.Strings.To_Universal_String ("O1"), PL));

      PL := C.Create_Production_List;
      PL.Add (P1);
      C.Create_Non_Terminal (League.Strings.To_Universal_String ("NT1"), PL);
   end;

   C.Create_Attribute_Declaration
     (League.Strings.To_Universal_String ("T2"),
      League.Strings.To_Universal_String ("AT2"),
      League.Strings.To_Universal_String ("Integer"));

   C.Create_Attribute_Declaration
     (League.Strings.To_Universal_String ("T3"),
      League.Strings.To_Universal_String ("AT3"),
      League.Strings.To_Universal_String ("Integer"));

--  NT2 := /P2/ { /PL1/ T3 }
--  L1.L1s := F (T3.AT3)

   C.Create_Attribute_Declaration
     (League.Strings.To_Universal_String ("L1"),
      League.Strings.To_Universal_String ("L1s"),
      False,
      League.Strings.To_Universal_String ("Integer"));

   C.Create_Rule
     (League.Strings.To_Universal_String ("L1"),
      League.Strings.To_Universal_String ("PL1"),
      League.Strings.To_Universal_String ("${L1.L1s} := F (${t3.AT3})"));

--  NT2 := /P2/ { /PL1/ T3 }
--  NT2.ANT2s := F (L1.L1s)
   C.Create_Attribute_Declaration
     (League.Strings.To_Universal_String ("NT2"),
      League.Strings.To_Universal_String ("ANT2s"),
      False,
      League.Strings.To_Universal_String ("Integer"));

   C.Create_Rule
     (League.Strings.To_Universal_String ("NT2"),
      League.Strings.To_Universal_String ("P2"),
      League.Strings.To_Universal_String ("${NT2.ANT2s} := F (${L1.L1s})"));

   declare
      Result : constant Anagram.Grammars.Grammar := C.Complete;
   begin
      Anagram.Grammars_Debug.Print (Result);
   end;
end TS_00005;
