------------------------------------------------------------------------------
--                        G E L A   G R A M M A R S                         --
--          Library for dealing with grammars for Gela project,             --
--                        a portable Ada compiler                           --
--                        http://gela.ada-ru.org/                           --
--                     - - - - - - - - - - - - - - -                        --
--              Read copyright and license in gela.ads file                 --
------------------------------------------------------------------------------
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
