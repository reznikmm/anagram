--  Check attributed grammar constructor and debuger output

with Gela.Grammars_Debug;
with Gela.Grammars.Attributed;
with Gela.Grammars.Attributed.Constructors;
with League.Strings;

procedure Main is
   C : aliased Gela.Grammars.Attributed.Constructors.Constructor;
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

   C.Create_Attribute_Declaration
     (League.Strings.To_Universal_String ("AT1"),
      League.Strings.To_Universal_String ("T1"));

   C.Create_Attribute_Declaration
     (League.Strings.To_Universal_String ("AT3"),
      League.Strings.To_Universal_String ("T3"));

   -- NT2 := T1 NT3
   --  NT2.ANT2s := F (T1.AT1)

   C.Set_Current_Non_Terminal (League.Strings.To_Universal_String ("NT2"));
   C.Create_Attribute_Declaration
     (League.Strings.To_Universal_String ("ANT2i"),
      True);
   C.Create_Attribute_Declaration
     (League.Strings.To_Universal_String ("ANT2s"),
      False);
   C.Set_Production
     (League.Strings.To_Universal_String ("P2"));

   C.Create_Rule
     (League.Strings.To_Universal_String ("ANT2s"));
   C.Create_Argument
     (League.Strings.To_Universal_String ("AT1"),
      League.Strings.To_Universal_String ("t1"));

   --  NT1 := NT3 NT2 T3
   --   NT2.ANT2i := F (T3.AT3)
   
   C.Set_Current_Non_Terminal (League.Strings.To_Universal_String ("NT1"));
   C.Set_Production
     (League.Strings.To_Universal_String ("P1"));

   C.Create_Rule
     (League.Strings.To_Universal_String ("nt2"),
      League.Strings.To_Universal_String ("ANT2i"));

   C.Create_Argument
     (League.Strings.To_Universal_String ("AT3"),
      League.Strings.To_Universal_String ("t3"));

   declare
      Result : Gela.Grammars.Attributed.Grammar := C.Complete;
   begin
      Gela.Grammars_Debug.Print (Result'Access);
   end;
end Main;
