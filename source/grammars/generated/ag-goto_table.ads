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
,(-12, 12),(-11, 9),(-10, 8),(-9, 7)
,(-8, 6),(-7, 5),(-6, 4),(-5, 3)
,(-4, 2),(-3, 1),(-2, 18)
-- State  1
,(-12, 12)
,(-11, 9),(-10, 8),(-9, 7),(-8, 6)
,(-7, 5),(-6, 4),(-5, 3),(-4, 19)

-- State  2

-- State  3

-- State  4

-- State  5

-- State  6

-- State  7

-- State  8

-- State  9

-- State  10
,(-12, 20)
-- State  11
,(-12, 21)
-- State  12

-- State  13

-- State  14

-- State  15
,(-12, 25)
-- State  16

-- State  17

-- State  18

-- State  19

-- State  20

-- State  21

-- State  22
,(-18, 36)
,(-17, 35),(-16, 34),(-15, 31),(-14, 32)
,(-12, 37)
-- State  23
,(-21, 40),(-19, 42),(-12, 41)

-- State  24
,(-21, 43),(-20, 44),(-12, 41)
-- State  25
,(-13, 46)

-- State  26
,(-21, 47),(-12, 41)
-- State  27

-- State  28

-- State  29
,(-13, 48)
-- State  30

-- State  31

-- State  32

-- State  33
,(-12, 51)

-- State  34
,(-18, 36),(-17, 52),(-12, 37)
-- State  35

-- State  36

-- State  37

-- State  38
,(-18, 36)
,(-17, 35),(-16, 34),(-15, 31),(-14, 54)
,(-12, 37)
-- State  39
,(-18, 36),(-17, 35),(-16, 34)
,(-15, 31),(-14, 55),(-12, 37)
-- State  40

-- State  41

-- State  42

-- State  43

-- State  44

-- State  45

-- State  46
,(-12, 59)

-- State  47

-- State  48
,(-12, 61)
-- State  49

-- State  50
,(-18, 36),(-17, 35),(-16, 34)
,(-15, 62),(-12, 37)
-- State  51

-- State  52

-- State  53
,(-12, 64)
-- State  54

-- State  55

-- State  56
,(-22, 68)
,(-12, 67)
-- State  57
,(-12, 69)
-- State  58
,(-22, 70),(-12, 67)

-- State  59

-- State  60

-- State  61

-- State  62

-- State  63
,(-18, 36),(-17, 35),(-16, 74),(-12, 37)

-- State  64

-- State  65

-- State  66

-- State  67

-- State  68

-- State  69

-- State  70

-- State  71

-- State  72
,(-23, 79)
-- State  73

-- State  74
,(-18, 36),(-17, 52),(-12, 37)

-- State  75

-- State  76
,(-21, 80),(-12, 41)
-- State  77
,(-21, 81),(-12, 41)

-- State  78

-- State  79

-- State  80

-- State  81

-- State  82

-- State  83

-- State  84

);
--  The offset vector
GOTO_OFFSET : constant array (0.. 84) of Integer :=
( 0,
 11, 20, 20, 20, 20, 20, 20, 20, 20, 20,
 21, 22, 22, 22, 22, 23, 23, 23, 23, 23,
 23, 23, 29, 32, 35, 36, 38, 38, 38, 39,
 39, 39, 39, 40, 43, 43, 43, 43, 49, 55,
 55, 55, 55, 55, 55, 55, 56, 56, 57, 57,
 62, 62, 62, 63, 63, 63, 65, 66, 68, 68,
 68, 68, 68, 72, 72, 72, 72, 72, 72, 72,
 72, 72, 73, 73, 76, 76, 78, 80, 80, 80,
 80, 80, 80, 80);

subtype Rule        is Natural;
subtype Nonterminal is Integer;

   Rule_Length : constant array (Rule range  0 ..  37) of Natural := ( 2,
 1, 1, 2, 1, 1, 1, 1, 1,
 1, 1, 3, 6, 3, 4, 1, 3,
 4, 1, 1, 2, 1, 4, 1, 3,
 3, 3, 3, 6, 6, 1, 7, 1,
 5, 1, 3, 1, 1);
   Get_LHS_Rule : constant array (Rule range  0 ..  37) of Nonterminal := (-1,
-2,-3,-3,-4,-4,-4,-4,-4,
-4,-4,-5,-5,-6,-7,-14,-14,
-15,-15,-16,-16,-17,-17,-18,-18,
-18,-8,-9,-19,-20,-22,-11,-23,
-10,-21,-21,-12,-13);
end Ag.Goto_Table;
