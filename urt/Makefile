# urt/Makefile -- the Ur/Web toolbox: the program and its checks.
#
#   make              build urt
#   make check        run urt/check
#   make clean
#
# The top-level Makefile.am calls in here for the same.

CC = cc
CFLAGS = -std=c99 -Wall -Wextra -O2

SRC = src/urt.c src/snapshot.c src/report.c src/fs.c src/tui.c
HDR = src/commands.h src/report.h src/fs.h src/tui.h

urt: $(SRC) $(HDR)
	$(CC) $(CFLAGS) -o urt $(SRC)

check: urt
	./check

clean:
	rm -f urt

.PHONY: check clean
