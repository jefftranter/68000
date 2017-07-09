# Build the tool for Linux.
trans09: trans09.pas
	fpc trans09.pas

# Run example under dosbox.
dos:
	dosbox -c "MOUNT C ${PWD}" -c "C:" -c "trans09 example.09 example.68" -c "EXIT"

# Run example under Linux.
linux:	trans09
	./trans09 example.09 example.68

# Run larger example under Linux.
testfile.out: trans09 testfile.asc
	./trans09 testfile.asc testfile.out

# Remove generated files.
clean:
	$(RM) trans09 trans09.o example.68 EXAMPLE.68 testfile.out error.txt ERROR.TXT
