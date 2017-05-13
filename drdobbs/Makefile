SUBDIRS = \
    binarysearch \
    nonuniformrandom \
    random \
    squareroot \
    tinybasic \
    worm

all:
	@for i in $(SUBDIRS); do \
	echo "make in $$i..."; \
	(cd "$$i"; $(MAKE) $(MFLAGS)); done

clean:
	@for i in $(SUBDIRS); do \
	echo "make clean in $$i..."; \
	(cd "$$i"; $(MAKE) $(MFLAGS) clean); done
