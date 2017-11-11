GPRBUILD_FLAGS = -p -j0
PREFIX                 ?= /usr
GPRDIR                 ?= $(PREFIX)/share/gpr
LIBDIR                 ?= $(PREFIX)/lib
INSTALL_PROJECT_DIR    ?= $(DESTDIR)$(GPRDIR)
INSTALL_INCLUDE_DIR    ?= $(DESTDIR)$(PREFIX)/include/anagram
INSTALL_LIBRARY_DIR    ?= $(DESTDIR)$(LIBDIR)
INSTALL_ALI_DIR        ?= ${INSTALL_LIBRARY_DIR}/anagram

GPRINSTALL_FLAGS = --prefix=$(PREFIX) --sources-subdir=$(INSTALL_INCLUDE_DIR)\
 --lib-subdir=$(INSTALL_ALI_DIR) --project-subdir=$(INSTALL_PROJECT_DIR)\
--link-lib-subdir=$(INSTALL_LIBRARY_DIR)
#INSTALL = install
#INSTALL_project = $(INSTALL) -m 644

all:
	gprbuild $(GPRBUILD_FLAGS) -P gnat/anagram.gpr
	gprbuild $(GPRBUILD_FLAGS) -P gnat/anagram_tests.gpr

install:
	gprinstall $(GPRINSTALL_FLAGS) -p -P gnat/anagram.gpr
#	$(INSTALL) -d ${INSTALL_PROJECT_DIR}
#	$(INSTALL_project) gnat/install/league.gpr  $(INSTALL_PROJECT_DIR)/matreshka_league.gpr
