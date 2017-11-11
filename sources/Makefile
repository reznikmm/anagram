LEXER=generated/gela-grammars-scanners-tables.adb\
generated/gela-grammars-scanners-on_accept.adb \
generated/gela-grammars-scanner_handlers.ads \
generated/gela-grammars-scanner_types.ads

PARSER=generated/ag-shift_reduce.ads \
generated/ag.adb \
generated/ag.ads \
generated/ag_tokens.ads \
generated/ag-goto_table.ads \


all: $(PARSER) $(LEXER)

$(LEXER): ag.l
	cd generated; uaflex --types Gela.Grammars.Scanner_Types \
           --scanner Gela.Grammars.Scanners \
           --handler Gela.Grammars.Scanner_Handlers \
           --tokens Ag_Tokens ../ag.l

$(PARSER): ag.y
	cd generated; ayacc ../ag.y
