package Ag.Goto_Table is

    type Small_Integer is range -32_000 .. 32_000;

    type Goto_Entry is record
        Nonterm  : Small_Integer;
        Newstate : Small_Integer;
    end record;

  --pragma suppress(index_check);

    subtype Row is Integer range -1 .. Integer'Last;

    type Goto_Parse_Table is array (Row range <>) of Goto_Entry;

    Goto_Matrix : constant Goto_Parse_Table :=
       ((-1,-1)  -- Dummy Entry.
-- State  0
,(-11, 11),(-10, 8),(-9, 7),(-8, 6)
,(-7, 5),(-6, 4),(-5, 3),(-4, 2)
,(-3, 1),(-2, 16)
-- State  1
,(-11, 11),(-10, 8)
,(-9, 7),(-8, 6),(-7, 5),(-6, 4)
,(-5, 3),(-4, 17)
-- State  2

-- State  3

-- State  4

-- State  5

-- State  6

-- State  7

-- State  8

-- State  9
,(-11, 18)
-- State  10
,(-11, 19)

-- State  11

-- State  12

-- State  13

-- State  14

-- State  15

-- State  16

-- State  17

-- State  18

-- State  19

-- State  20
,(-16, 32),(-15, 31),(-14, 30),(-13, 27)
,(-12, 28),(-11, 33)
-- State  21
,(-19, 36),(-17, 38)
,(-11, 37)
-- State  22
,(-19, 39),(-18, 40),(-11, 37)

-- State  23
,(-19, 41),(-11, 37)
-- State  24

-- State  25

-- State  26

-- State  27

-- State  28

-- State  29
,(-11, 44)
-- State  30
,(-16, 32)
,(-15, 45),(-11, 33)
-- State  31

-- State  32

-- State  33

-- State  34
,(-16, 32),(-15, 31)
,(-14, 30),(-13, 27),(-12, 47),(-11, 33)

-- State  35
,(-16, 32),(-15, 31),(-14, 30),(-13, 27)
,(-12, 48),(-11, 33)
-- State  36

-- State  37

-- State  38

-- State  39

-- State  40

-- State  41

-- State  42

-- State  43
,(-16, 32),(-15, 31)
,(-14, 30),(-13, 53),(-11, 33)
-- State  44

-- State  45

-- State  46
,(-11, 55)

-- State  47

-- State  48

-- State  49
,(-20, 59),(-11, 58)
-- State  50
,(-11, 60)
-- State  51
,(-20, 61)
,(-11, 58)
-- State  52

-- State  53

-- State  54
,(-16, 32),(-15, 31),(-14, 63)
,(-11, 33)
-- State  55

-- State  56

-- State  57

-- State  58

-- State  59

-- State  60

-- State  61

-- State  62
,(-21, 68)
-- State  63
,(-16, 32),(-15, 45)
,(-11, 33)
-- State  64

-- State  65
,(-19, 69),(-11, 37)
-- State  66
,(-19, 70)
,(-11, 37)
-- State  67

-- State  68

-- State  69

-- State  70

-- State  71

-- State  72

-- State  73

);
--  The offset vector
GOTO_OFFSET : constant array (0.. 73) of Integer :=
( 0,
 10, 18, 18, 18, 18, 18, 18, 18, 18, 19,
 20, 20, 20, 20, 20, 20, 20, 20, 20, 20,
 26, 29, 32, 34, 34, 34, 34, 34, 34, 35,
 38, 38, 38, 38, 44, 50, 50, 50, 50, 50,
 50, 50, 50, 55, 55, 55, 56, 56, 56, 58,
 59, 61, 61, 61, 65, 65, 65, 65, 65, 65,
 65, 65, 66, 69, 69, 71, 73, 73, 73, 73,
 73, 73, 73);

subtype Rule        is Natural;
subtype Nonterminal is Integer;

   Rule_Length : constant array (Rule range  0 ..  33) of Natural := ( 2,
 1, 1, 2, 1, 1, 1, 1, 1,
 1, 3, 3, 4, 1, 3, 4, 1,
 1, 2, 1, 4, 1, 3, 3, 3,
 3, 6, 6, 1, 7, 1, 1, 3,
 1);
   Get_LHS_Rule : constant array (Rule range  0 ..  33) of Nonterminal := (-1,
-2,-3,-3,-4,-4,-4,-4,-4,
-4,-5,-6,-7,-12,-12,-13,-13,
-14,-14,-15,-15,-16,-16,-16,-8,
-9,-17,-18,-20,-10,-21,-19,-19,
-11);
end Ag.Goto_Table;
