# actors-rts Makefile: creates/installs actors run-time

MAJOR=1
MINOR=0
BUILD=

ifeq "$(BUILD)" ""
MINOR_DOT_BUILD=$(MINOR)
else
MINOR_DOT_BUILD=$(MINOR).$(BUILD)
endif

BASENAME=libactors-rts
REAL_NAME=$(BASENAME).a

ifneq "$(PROFILE)" ""
override CFLAGS += -pg -fno-omit-frame-pointer
endif

override CFLAGS += `xml2-config --cflags`

# Enable action tracing in the system actors
override CFLAGS += -DTRACE

#override CFLAGS += -O3
override CFLAGS += -g

INSTALL_H=actors-rts.h actors-fifo.h actors-config.h dll.h natives.h

INSTALL_SYSACTORS=art_DDRModel.cal art_Display_yuv.cal art_Sink_yuv.cal \
                  art_Sink_bin.cal art_Sink_txt.cal art_Sink_real.cal \
                  art_Source_bin.cal art_Source_txt.cal art_Source_real.cal \
                  art_Streaming.cal art_Display_yuv_width_height.cal

INSTALL_C_SRC=display.h display-fb.c display-sdl.c display-gtk.c display-null.c \
              display-file.c internal.h xmlParser.h

OBJECTS=actors-rts.o xmlParser.o xmlTrace.o termination-report.o \
        art_Sink_bin.o art_Sink_txt.o art_Sink_real.o \
	    art_Source_bin.o art_Source_txt.o art_Source_real.o \
        art_DDRModel.o art_Display_yuv.o display.o \
		art_Streaming.o art_Display_yuv_width_height.o

# delete the built-in suffixes to avoid surprises
.SUFFIXES:   

# Directories

srcdir?=.
prefix?=.
exec_prefix?=$(prefix)
includedir?=$(prefix)/include
libdir?=$(exec_prefix)/lib
datarootdir?=$(prefix)/share
datadir?=$(datarootdir)

override LDLIBS += -lpthread -lc

.PHONY: all uninstall clean
.PHONY: install install-lib install-include install-sysactors 

all: $(REAL_NAME)

$(REAL_NAME): $(OBJECTS)
	$(AR) rcs $@ $^

$(OBJECTS): %.o : $(srcdir)/%.c
	$(CC) -fPIC -c -Wall $(CFLAGS) -o $@ $<

install: install-lib install-include install-sysactors

install-lib:
	@mkdir -p $(libdir)
	@cp $(REAL_NAME) $(libdir)/.

install-include:
	@mkdir -p $(includedir)
	@cp $(INSTALL_H:%=$(srcdir)/%) $(includedir)/.

install-sysactors:
	@mkdir -p $(datadir)/sysactors/cal
	@mkdir -p $(datadir)/sysactors/c
	@cp $(INSTALL_SYSACTORS:%=$(srcdir)/sysactors/%) $(datadir)/sysactors/cal/.
	@cp $(INSTALL_C_SRC:%=$(srcdir)/%) $(datadir)/sysactors/c/.

INSTALLED_FILES=$(libdir)/$(REAL_NAME) \
                $(INSTALL_H:%=$(includedir)/%) \
                $(INSTALL_SYSACTORS:%=$(datadir)/sysactors/cal/%) \
                $(INSTALL_C_SRC:%=$(datadir)/sysactors/c/%)

uninstall:
	@rm -f $(INSTALLED_FILES)

clean:
	@rm -f *.o $(REAL_NAME) *.a *~

