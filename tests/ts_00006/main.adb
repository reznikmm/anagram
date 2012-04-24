--  Check extended attributed grammar convertor

with Gela.Grammars_Convertors;
with Gela.Grammars_Debug;
with Gela.Grammars.Attributed.Extended;
with Gela.Grammars.Attributed.Extended.Constructors;
with League.Strings;

--  NT2 := /P2/ NT1 { /PL1/ T3 }
--  NT1 := /P1/ T1 [ /OP1/ T2 NT2 ]

procedure Main is
   C : aliased Gela.Grammars.Attributed.Extended.Constructors.Constructor;
begin
   C.Create_Terminal (League.Strings.To_Universal_String ("T2"));
   C.Create_Terminal (League.Strings.To_Universal_String ("T1"));
   C.Create_Terminal (League.Strings.To_Universal_String ("T3"));

   C.Create_Non_Terminal (League.Strings.To_Universal_String ("NT2"));

   C.Create_Production (League.Strings.To_Universal_String ("P2"));
   
   begin
      C.Create_Non_Terminal_Reference
        (League.Strings.To_Universal_String ("nt1"),
         League.Strings.To_Universal_String ("NT1"));
      C.Create_List (League.Strings.To_Universal_String ("L1"));
      C.Create_Production (League.Strings.To_Universal_String ("PL1"));
      C.Create_Terminal_Reference
        (League.Strings.To_Universal_String ("t3"),
         League.Strings.To_Universal_String ("T3"));
      C.End_List;
   end;
   
   C.Create_Non_Terminal (League.Strings.To_Universal_String ("NT1"));
   C.Create_Production (League.Strings.To_Universal_String ("P1"));
   
   begin
      C.Create_Terminal_Reference
        (League.Strings.To_Universal_String ("t1"),
         League.Strings.To_Universal_String ("T1"));
      C.Create_Option (League.Strings.To_Universal_String ("O1"));
      C.Create_Production (League.Strings.To_Universal_String ("OP1"));
      C.Create_Terminal_Reference
        (League.Strings.To_Universal_String ("t2"),
         League.Strings.To_Universal_String ("T2"));
      C.Create_Non_Terminal_Reference
        (League.Strings.To_Universal_String ("nt2"),
         League.Strings.To_Universal_String ("NT2"));
      C.End_Option;
   end;
   
   C.Create_Attribute_Declaration
     (League.Strings.To_Universal_String ("AT2"),
      League.Strings.To_Universal_String ("Integer"),
      League.Strings.To_Universal_String ("T2"));

   C.Create_Attribute_Declaration
     (League.Strings.To_Universal_String ("AT3"),
      League.Strings.To_Universal_String ("Integer"),
      League.Strings.To_Universal_String ("T3"));

--  NT2 := /P2/ { /PL1/ T3 }
--  L1.L1s := F (T3.AT3)
   
   C.Set_Current_Non_Terminal (League.Strings.To_Universal_String ("NT2"));
   C.Set_Production
     (League.Strings.To_Universal_String ("P2"));
   C.Set_Current_List (League.Strings.To_Universal_String ("L1"));
   
   C.Create_Attribute_Declaration
     (League.Strings.To_Universal_String ("L1s"),
      League.Strings.To_Universal_String ("Integer"),
      False);
   
   C.Set_Production (League.Strings.To_Universal_String ("PL1"));
   C.Create_Rule
     (League.Strings.To_Universal_String ("L1s"),
      League.Strings.To_Universal_String ("null;"));
   C.Create_Argument
     (League.Strings.To_Universal_String ("AT3"),
      League.Strings.To_Universal_String ("t3"));
   
--  NT2 := /P2/ { /PL1/ T3 }
--  NT2.ANT2s := F (L1.L1s)
   C.Set_Current_Non_Terminal (League.Strings.To_Universal_String ("NT2"));
   C.Create_Attribute_Declaration
     (League.Strings.To_Universal_String ("ANT2s"),
      League.Strings.To_Universal_String ("Integer"),
      False);
   C.Set_Production
     (League.Strings.To_Universal_String ("P2"));

   C.Create_Rule
     (League.Strings.To_Universal_String ("ANT2s"),
      League.Strings.To_Universal_String ("null;"));
   C.Create_Argument
     (League.Strings.To_Universal_String ("L1s"),
      League.Strings.To_Universal_String ("L1"));

   declare
      Extended : aliased Gela.Grammars.Attributed.Extended.Grammar :=
        C.Complete;
      Plain    : aliased Gela.Grammars.Attributed.Grammar :=
        Gela.Grammars_Convertors.Convert (Extended'Access, Left => False);
   begin
      Gela.Grammars_Debug.Print (Plain'Access);
   end;
end Main;
