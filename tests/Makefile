TEST_HOME?=/tmp/gela

vpath %.tr $(TEST_HOME)

TESTS=$(wildcard ts_*)

# all: mkdir tests

tests: $(patsubst ts_%,%.tr,$(TESTS))

%.tr: ts_%
	gprbuild -p -aP ../source/ \
		-XGELA_LIB_DIR=$(TEST_HOME)/gela \
		-XSOURCE_DIR=$< \
		-XOBJECT_DIR=$(TEST_HOME)/$< \
		-P $(firstword $(wildcard $</*.gpr) simple.gpr) main.adb
	cd $<; $(TEST_HOME)/$</main > $(TEST_HOME)/$@
	if [ -f $</$<.out ];\
		then diff -u $</$<.out $(TEST_HOME)/$@ ;\
		else echo "OK" | cmp $(TEST_HOME)/$@ ;\
	fi

gelalib: ../source
	gprbuild -p -P ../source/gela.gpr \
		-XGELA_LIB_DIR=$(TEST_HOME)/gela

mkdir:
	rm -rf $(TEST_HOME)
	mkdir -p $(TEST_HOME)