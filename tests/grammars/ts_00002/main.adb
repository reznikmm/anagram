--  Check basic grammar constructor and debuger output

with Gela.Grammars_Debug;
with Gela.Grammars;
with Gela.Grammars.Constructors;
with League.Strings;

procedure Main is
   C : aliased Gela.Grammars.Constructors.Constructor;
begin
   C.Create_Terminal (League.Strings.To_Universal_String ("T2"));
   C.Create_Terminal (League.Strings.To_Universal_String ("T1"));
   C.Create_Terminal (League.Strings.To_Universal_String ("T3"));
   
   C.Create_Non_Terminal (League.Strings.To_Universal_String ("NT2"));
   
   C.Create_Production (League.Strings.To_Universal_String ("P2"));
   C.Create_Terminal_Reference
     (League.Strings.To_Universal_String ("t1"),
      League.Strings.To_Universal_String ("T1"));
   C.Create_Non_Terminal_Reference
     (League.Strings.To_Universal_String ("nt3"),
      League.Strings.To_Universal_String ("NT3"));
   
   C.Create_Non_Terminal (League.Strings.To_Universal_String ("NT1"));
   C.Create_Production (League.Strings.To_Universal_String ("P1"));
   C.Create_Non_Terminal_Reference
     (League.Strings.To_Universal_String ("nt3"),
      League.Strings.To_Universal_String ("NT3"));
   C.Create_Non_Terminal_Reference
     (League.Strings.To_Universal_String ("nt2"),
      League.Strings.To_Universal_String ("NT2"));
   C.Create_Terminal_Reference
     (League.Strings.To_Universal_String ("t3"),
      League.Strings.To_Universal_String ("T3"));
   
   C.Create_Non_Terminal (League.Strings.To_Universal_String ("NT3"));
   C.Create_Production (League.Strings.To_Universal_String ("P3"));
   C.Create_Terminal_Reference
     (League.Strings.To_Universal_String ("t2"),
      League.Strings.To_Universal_String ("T2"));
   C.Create_Non_Terminal_Reference
     (League.Strings.To_Universal_String ("nt1"),
      League.Strings.To_Universal_String ("NT1"));
   
   declare
      Result : Gela.Grammars.Grammar := C.Complete;
   begin
      Gela.Grammars_Debug.Print (Result'Access);
   end;
end Main;
