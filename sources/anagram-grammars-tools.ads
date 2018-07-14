--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

package Anagram.Grammars.Tools is
   pragma Preelaborate;

   ε : constant Terminal_Count := 0;

   type Terminal_Set_Indexed_By_Production is
     array (Production_Index range <>,
            Terminal_Count   range <>)
     of Boolean;  --  with Pack; <= Cause a bug in gcc 8 (bug 86514)

   type Terminal_Set_Per_Production
     (Last_Terminal   : Terminal_Count;
      Last_Production : Production_Count) is
   record
      Map : Terminal_Set_Indexed_By_Production
        (1 .. Last_Production, 0 .. Last_Terminal);
   end record;

   type Terminal_Set_Indexed_By_Non_Terminal is
     array (Non_Terminal_Index range <>,
            Terminal_Count     range <>)
     of Boolean;  --  with Pack; <= Cause a bug in gcc 8 (bug 86514)

   type Terminal_Set_Per_Non_Terminal
     (Last_Terminal     : Terminal_Count;
      Last_Non_Terminal : Non_Terminal_Count) is
   record
      Map : Terminal_Set_Indexed_By_Non_Terminal
        (1 .. Last_Non_Terminal, 0 .. Last_Terminal);
   end record;

   type Non_Terminal_Set_Indexed_By_Production is
     array (Production_Index range <>,
            Non_Terminal_Index   range <>)
     of Boolean;  --  with Pack; <= Cause a bug in gcc 8 (bug 86514)

   type Non_Terminal_Set_Per_Production
     (Last_Non_Terminal : Non_Terminal_Count;
      Last_Production   : Production_Count) is
   record
      Map : Non_Terminal_Set_Indexed_By_Production
        (1 .. Last_Production, 1 .. Last_Non_Terminal);
   end record;

   type Non_Terminal_Set_Indexed_By_Non_Terminal is
     array (Non_Terminal_Index range <>,
            Non_Terminal_Index range <>)
     of Boolean;  --  with Pack; <= Cause a bug in gcc 8 (bug 86514)

   type Non_Terminal_Set_Per_Non_Terminal
     (Last_Non_Terminal : Non_Terminal_Count) is
   record
      Map : Non_Terminal_Set_Indexed_By_Non_Terminal
        (1 .. Last_Non_Terminal, 1 .. Last_Non_Terminal);
   end record;

   procedure Get_First
     (Input    : Grammar;
      Value    : out Terminal_Set_Per_Production;
      Value_NT : out Non_Terminal_Set_Per_Production);

   procedure Get_First
     (Input : Grammar;
      Value : out Terminal_Set_Per_Production);

   procedure Get_First
     (Input    : Grammar;
      Value    : out Terminal_Set_Per_Non_Terminal;
      Value_NT : out Non_Terminal_Set_Per_Non_Terminal);

   procedure Get_First
     (Input : Grammar;
      Value : out Terminal_Set_Per_Non_Terminal);

   procedure Get_Follow
     (Input : Grammar;
      First : Terminal_Set_Per_Non_Terminal;
      Value : out Terminal_Set_Per_Non_Terminal);

   procedure Get_Follow
     (Input    : Grammar;
      First    : Terminal_Set_Per_Non_Terminal;
      First_NT : Non_Terminal_Set_Per_Non_Terminal;
      Value    : out Terminal_Set_Per_Non_Terminal;
      Value_NT : out Non_Terminal_Set_Per_Non_Terminal);

end Anagram.Grammars.Tools;
