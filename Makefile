
PREFIX=/usr

PROJECT=thekraken
PROJ_CFLAGS=-Wall -Wshadow -D_GNU_SOURCE -O2 $(CFLAGS)
PROJ_LDFLAGS=$(LDFLAGS)
PROJ_LIBS=$(LIBS) -lrt -lm

OBJROOT=obj
OBJDIR=$(OBJROOT)

SOURCES=thekraken.c synthload.c

OBJECTS=$(SOURCES:%.c=$(OBJDIR)/%.o)
DEPS=$(SOURCES:%.c=$(OBJDIR)/.%.d)

GENERATED=thekraken.cfg thekraken.log thekraken-prev.log .thekraken-timeref

all: $(OBJDIR) $(PROJECT)

install:
	install -ps $(PROJECT) $(PREFIX)/bin

uninstall:
	$(RM) $(PREFIX)/bin/$(PROJECT)

$(PROJECT): version.h $(OBJECTS)
	echo "/* this file is autogenerated */" > build_info.h
	echo "#define BUILD_INFO \"(compiled `date` by `whoami`@`hostname`)\"" >> build_info.h
	$(CC) $(PROJ_CFLAGS) -c -o $(OBJDIR)/build.o build.c
	$(CC) $(PROJ_LDFLAGS) -o $@ $(OBJECTS) $(OBJDIR)/build.o $(PROJ_LIBS)

$(OBJDIR)/%.o: %.c
	$(CC) $(PROJ_CFLAGS) -MMD -MF $(<:%.c=$(OBJDIR)/.%.d) -MT $(<:%.c=$(OBJDIR)/%.o) -c -o $@ $<

$(OBJDIR):
	mkdir -p $(OBJDIR)

clean:
	$(RM) $(OBJECTS) $(OBJDIR)/build.o $(PROJECT)
	
distclean: clean
	$(RM) build_info.h version.h
	$(RM) -r $(OBJROOT)
	$(RM) core core.[0-9]
	$(RM) *~ DEADJOE *.orig *.rej *.i *.r[0-9]* *.mine
	$(RM) $(GENERATED)

version.h: VERSION
	echo "/* this file is autogenerated */" > version.h
	echo "#define VERSION \"`cat VERSION`\"" >> version.h

.PHONY: clean distclean all install uninstall

-include $(DEPS)
