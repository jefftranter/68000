SUBDIRS = c_example drdobbs figforth newlib_example testprog tutor ehbasic leventhal monitor rpncalc

all:
	@for i in $(SUBDIRS); do \
	(cd "$$i"; $(MAKE) $(MFLAGS)); done

clean:
	@for i in $(SUBDIRS); do \
	(cd "$$i"; $(MAKE) $(MFLAGS) clean); done
