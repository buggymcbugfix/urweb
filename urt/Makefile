# urt/Makefile -- the Ur/Web toolbox: the program and its checks.
#
#   make              build urt from the C beside it
#   make check        run urt/check
#   make clean
#
# The top-level Makefile.am calls in here for the same.

CC = cc
CFLAGS = -std=c99 -Wall -Wextra -O2

SRC = urt.c snapshot.c report.c fs.c tui.c
HDR = commands.h report.h fs.h tui.h

urt: $(SRC) $(HDR)
	$(CC) $(CFLAGS) -o urt $(SRC)

check: urt
	./check

clean:
	rm -f urt

.PHONY: check clean
