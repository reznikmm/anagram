--  Copyright (c) 2010-2017 Maxim Reznik <reznikmm@gmail.com>
--
--  SPDX-License-Identifier: MIT
--  License-Filename: LICENSE
-------------------------------------------------------------

--  This package resolves conflict in a parse table using precedence and
--  associativiti information of terminals and productions.

with Anagram.Grammars.LR;
with Anagram.Grammars.LR_Tables;
with Ada.Containers.Ordered_Maps;

package Anagram.Grammars.Conflicts is

   type Resolver is tagged private;

   procedure Resolve
     (Self  : in out Resolver;
      Input : Grammar;
      Table : in out LR_Tables.Table);

private

   package Priority_Maps is new Ada.Containers.Ordered_Maps
     (Precedence_Level, Associate_Kind);

   type Resolver is tagged record
      Checks : Priority_Maps.Map;
   end record;

   procedure Check_Priority
     (Self : in out Resolver;
      Prec : Precedence_Value);

   procedure Try_To_Resolve
     (Self     : in out Resolver;
      Input    : Grammar;
      Table    : in out LR_Tables.Table;
      State    : LR.State_Index;
      Terminal : Terminal_Index);

end Anagram.Grammars.Conflicts;
