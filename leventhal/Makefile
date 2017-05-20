SUBDIRS = ch04 ch05 ch06 ch07 ch08

all:
	@for i in $(SUBDIRS); do \
	(cd "$$i"; $(MAKE) $(MFLAGS)); done

clean:
	@for i in $(SUBDIRS); do \
	(cd "$$i"; $(MAKE) $(MFLAGS) clean); done
