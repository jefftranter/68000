SUBDIRS = c_example drdobbs ehbasic figforth leventhal monitor newlib_example rockpaperscissors rpncalc testprog tutor xlate09

all:
	@for i in $(SUBDIRS); do \
	(cd "$$i"; $(MAKE) -s $(MFLAGS)); done

clean:
	@for i in $(SUBDIRS); do \
	(cd "$$i"; $(MAKE) -s $(MFLAGS) clean); done
