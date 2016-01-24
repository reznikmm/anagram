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
,(-13, 13),(-12, 10),(-11, 9),(-10, 8)
,(-9, 7),(-8, 6),(-7, 5),(-6, 4)
,(-5, 3),(-4, 2),(-3, 1),(-2, 20)

-- State  1
,(-13, 13),(-12, 10),(-11, 9),(-10, 8)
,(-9, 7),(-8, 6),(-7, 5),(-6, 4)
,(-5, 3),(-4, 21)
-- State  2

-- State  3

-- State  4

-- State  5

-- State  6

-- State  7

-- State  8

-- State  9

-- State  10

-- State  11
,(-13, 22)
-- State  12
,(-13, 23)

-- State  13

-- State  14

-- State  15

-- State  16

-- State  17
,(-13, 28)
-- State  18

-- State  19

-- State  20

-- State  21

-- State  22

-- State  23

-- State  24
,(-19, 39),(-18, 38),(-17, 37)
,(-16, 34),(-15, 35),(-13, 40)
-- State  25
,(-23, 43)
,(-20, 45),(-13, 44)
-- State  26
,(-23, 46),(-21, 47)
,(-13, 44)
-- State  27
,(-23, 48),(-22, 49),(-13, 44)

-- State  28
,(-14, 51)
-- State  29
,(-23, 52),(-13, 44)
-- State  30

-- State  31

-- State  32
,(-14, 53)

-- State  33

-- State  34

-- State  35

-- State  36
,(-13, 56)
-- State  37
,(-19, 39),(-18, 57),(-13, 40)

-- State  38

-- State  39

-- State  40

-- State  41
,(-19, 39),(-18, 38),(-17, 37),(-16, 34)
,(-15, 59),(-13, 40)
-- State  42
,(-19, 39),(-18, 38)
,(-17, 37),(-16, 34),(-15, 60),(-13, 40)

-- State  43

-- State  44

-- State  45

-- State  46

-- State  47

-- State  48

-- State  49

-- State  50

-- State  51
,(-13, 65)
-- State  52

-- State  53
,(-13, 67)
-- State  54

-- State  55
,(-19, 39),(-18, 38)
,(-17, 37),(-16, 68),(-13, 40)
-- State  56

-- State  57

-- State  58
,(-13, 70)

-- State  59

-- State  60

-- State  61
,(-24, 74),(-13, 73)
-- State  62
,(-13, 75)
-- State  63
,(-24, 76)
,(-13, 73)
-- State  64
,(-24, 77),(-13, 73)
-- State  65

-- State  66

-- State  67

-- State  68

-- State  69
,(-19, 39)
,(-18, 38),(-17, 81),(-13, 40)
-- State  70

-- State  71

-- State  72

-- State  73

-- State  74

-- State  75

-- State  76

-- State  77

-- State  78

-- State  79
,(-25, 87)

-- State  80

-- State  81
,(-19, 39),(-18, 57),(-13, 40)
-- State  82

-- State  83
,(-23, 88)
,(-13, 44)
-- State  84
,(-23, 89),(-13, 44)
-- State  85
,(-23, 90)
,(-13, 44)
-- State  86

-- State  87

-- State  88

-- State  89

-- State  90

-- State  91

-- State  92

-- State  93

-- State  94

);
--  The offset vector
GOTO_OFFSET : constant array (0.. 94) of Integer :=
( 0,
 12, 22, 22, 22, 22, 22, 22, 22, 22, 22,
 22, 23, 24, 24, 24, 24, 24, 25, 25, 25,
 25, 25, 25, 25, 31, 34, 37, 40, 41, 43,
 43, 43, 44, 44, 44, 44, 45, 48, 48, 48,
 48, 54, 60, 60, 60, 60, 60, 60, 60, 60,
 60, 61, 61, 62, 62, 67, 67, 67, 68, 68,
 68, 70, 71, 73, 75, 75, 75, 75, 75, 79,
 79, 79, 79, 79, 79, 79, 79, 79, 79, 80,
 80, 83, 83, 85, 87, 89, 89, 89, 89, 89,
 89, 89, 89, 89);

subtype Rule        is Natural;
subtype Nonterminal is Integer;

   Rule_Length : constant array (Rule range  0 ..  40) of Natural := ( 2,
 1, 1, 2, 1, 1, 1, 1, 1,
 1, 1, 1, 3, 6, 3, 4, 1,
 3, 4, 1, 1, 2, 1, 4, 1,
 3, 3, 3, 3, 3, 6, 6, 6,
 1, 7, 1, 5, 1, 3, 1, 1);
   Get_LHS_Rule : constant array (Rule range  0 ..  40) of Nonterminal := (-1,
-2,-3,-3,-4,-4,-4,-4,-4,
-4,-4,-4,-5,-5,-6,-7,-15,
-15,-16,-16,-17,-17,-18,-18,-19,
-19,-19,-8,-9,-10,-20,-21,-22,
-24,-12,-25,-11,-23,-23,-13,-14);
end Ag.Goto_Table;
