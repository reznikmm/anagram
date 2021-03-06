--  Check extended grammar constructor and debuger output

with Anagram.Grammars_Debug;
with Anagram.Grammars;
with Anagram.Grammars.Constructors;
with League.Strings;

procedure TS_00003 is
   use Anagram.Grammars.Constructors;
   C : Anagram.Grammars.Constructors.Constructor;
begin
   C.Create_Terminal (League.Strings.To_Universal_String ("T2"));
   C.Create_Terminal (League.Strings.To_Universal_String ("T1"));
   C.Create_Terminal (League.Strings.To_Universal_String ("T3"));

   declare
      T1 : constant Part := C.Create_Terminal_Reference
        (League.Strings.To_Universal_String ("t1"),
         League.Strings.To_Universal_String ("T1"));

      NT3 : constant Part := C.Create_Non_Terminal_Reference
        (League.Strings.To_Universal_String ("nt3"),
         League.Strings.To_Universal_String ("NT3"));
      P2 : Production := C.Create_Production
        (League.Strings.To_Universal_String ("P2"));
      PL : Production_List := C.Create_Production_List;
   begin
      P2.Add (T1);
      P2.Add (NT3);
      PL.Add (P2);
      C.Create_Non_Terminal (League.Strings.To_Universal_String ("NT2"), PL);
   end;

   declare
      NT3 : constant Part := C.Create_Non_Terminal_Reference
        (League.Strings.To_Universal_String ("nt3"),
         League.Strings.To_Universal_String ("NT3"));

      L1 : constant Part := C.Create_List_Reference
        (League.Strings.To_Universal_String ("L1"),
         League.Strings.To_Universal_String ("L1"));

      P1 : Production := C.Create_Production
        (League.Strings.To_Universal_String ("P1"));

      PL : Production_List := C.Create_Production_List;
   begin
      P1.Add (NT3);
      P1.Add (L1);
      PL.Add (P1);
      C.Create_Non_Terminal (League.Strings.To_Universal_String ("NT1"), PL);
   end;

   declare
      NT2 : constant Part := C.Create_Non_Terminal_Reference
        (League.Strings.To_Universal_String ("nt2"),
         League.Strings.To_Universal_String ("NT2"));

      T3 : constant Part := C.Create_Terminal_Reference
        (League.Strings.To_Universal_String ("t3"),
         League.Strings.To_Universal_String ("T3"));

      PL1 : Production := C.Create_Production
        (League.Strings.To_Universal_String ("PL1"));

      PL : Production_List := C.Create_Production_List;
   begin
      PL1.Add (NT2);
      PL1.Add (T3);
      PL.Add (PL1);
      C.Create_List (League.Strings.To_Universal_String ("L1"), PL);
   end;

   declare
      T2 : constant Part := C.Create_Terminal_Reference
        (League.Strings.To_Universal_String ("t2"),
         League.Strings.To_Universal_String ("T2"));

      NT1 : constant Part := C.Create_Non_Terminal_Reference
        (League.Strings.To_Universal_String ("nt1"),
         League.Strings.To_Universal_String ("NT1"));

      OP3 : Production := C.Create_Production
        (League.Strings.To_Universal_String ("OP3"));

      P3 : Production := C.Create_Production
        (League.Strings.To_Universal_String ("P3"));

      PL : Production_List := C.Create_Production_List;
   begin
      OP3.Add (T2);
      OP3.Add (NT1);
      PL.Add (OP3);
      P3.Add (C.Create_Option (League.Strings.To_Universal_String ("O3"), PL));

      PL := C.Create_Production_List;
      PL.Add (P3);
      C.Create_Non_Terminal (League.Strings.To_Universal_String ("NT3"), PL);
   end;

   declare
      Result : constant Anagram.Grammars.Grammar := C.Complete;
   begin
      Anagram.Grammars_Debug.Print (Result);
   end;
end TS_00003;
