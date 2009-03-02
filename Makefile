#
# MicroGrid Simulator
#
# Makefile for Linux.
#
all: debug release
release: MGAlpha MGSparc
debug: MGAlpha.dbg MGSparc.dbg
alpha Alpha: MGAlpha MGAlpha.dbg
sparc Sparc: MGSparc MGSparc.dbg

CC               = g++
CPPFLAGS_COMMON  = -Wall
CPPFLAGS_RELEASE = $(CPPFLAGS_COMMON) -O2 -DNDEBUG
CPPFLAGS_DEBUG   = $(CPPFLAGS_COMMON) -O0 -g
CPPFLAGS_ALPHA   = -DTARGET_ARCH=ARCH_ALPHA
CPPFLAGS_SPARC   = -DTARGET_ARCH=ARCH_SPARC

OBJDIR   = objs
DEPDIR   = deps
LDFLAGS  = -lreadline -lncurses
OBJS     = $(patsubst %.cpp,$(OBJDIR)/%.o,$(wildcard *.cpp))
DEPS     = $(patsubst %.cpp,$(DEPDIR)/%.d,$(wildcard *.cpp))

.PHONY: clean tidy all debug release
.SUFFIXES:
.SILENT:

OBJS_COMMON = $(foreach f,$(OBJS),$(if $(findstring .,$(f:.o=)),,$f))
OBJS_ALPHA  = $(filter %.alpha.o,$(OBJS)) $(OBJS_COMMON)
OBJS_SPARC  = $(filter %.sparc.o,$(OBJS)) $(OBJS_COMMON)

MGAlpha.dbg: $(subst .o,.alpha.dbg.o,$(OBJS_ALPHA))
	echo LINK $@
	$(CC) $(LDFLAGS) -o $@ $^

MGAlpha: $(subst .o,.alpha.o,$(OBJS_ALPHA))
	echo LINK $@
	$(CC) $(LDFLAGS) -o $@ $^

MGSparc.dbg: $(subst .o,.sparc.dbg.o,$(OBJS_SPARC))
	echo LINK $@
	$(CC) $(LDFLAGS) -o $@ $^

MGSparc: $(subst .o,.sparc.o,$(OBJS_SPARC))
	echo LINK $@
	$(CC) $(LDFLAGS) -o $@ $^

-include $(DEPDIR)/*.d
Makefile: $(DEPS)

$(OBJDIR)/%.alpha.dbg.o: %.cpp
	echo [Alpha.dbg] CC $*.o
	if [ ! -e $(OBJDIR) ]; then mkdir -p $(OBJDIR); fi
	$(CC) -c $(CPPFLAGS_DEBUG) $(CPPFLAGS_ALPHA) -o $@ $<

$(OBJDIR)/%.alpha.o: %.cpp
	echo [Alpha] CC $*.o
	if [ ! -e $(OBJDIR) ]; then mkdir -p $(OBJDIR); fi
	$(CC) -c $(CPPFLAGS_RELEASE) $(CPPFLAGS_ALPHA) -o $@ $<

$(OBJDIR)/%.sparc.dbg.o: %.cpp
	echo [Sparc.dbg] CC $*.o
	if [ ! -e $(OBJDIR) ]; then mkdir -p $(OBJDIR); fi
	$(CC) -c $(CPPFLAGS_DEBUG) $(CPPFLAGS_SPARC) -o $@ $<

$(OBJDIR)/%.sparc.o: %.cpp
	echo [Sparc] CC $*.o
	if [ ! -e $(OBJDIR) ]; then mkdir -p $(OBJDIR); fi
	$(CC) -c $(CPPFLAGS_RELEASE) $(CPPFLAGS_SPARC) -o $@ $<

$(DEPDIR)/%.d: %.cpp
	if [ ! -e $(DEPDIR) ]; then mkdir -p $(DEPDIR); fi
	$(CC) -MM $< | sed 's,\($*\)\.o[ :]*,$(OBJDIR)/\1.alpha.o $(OBJDIR)/\1.alpha.dbg.o $(OBJDIR)/\1.sparc.o $(OBJDIR)/\1.sparc.dbg.o $@ : ,g' > $@

tidy:
	@rm -rf $(OBJDIR)

clean: tidy
	@rm -rf MGAlpha MGAlpha.dbg MGSparc MGSparc.dbg $(DEPDIR)
