MIPS_TEST_SOURCES = \
    mips/simple.s

if ENABLE_MIPS_TESTS
TEST_ARCH       = mips
TEST_BINS       += $(MIPS_TEST_SOURCES:.s=.bin)
endif
