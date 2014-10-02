.PHONY: all install clean

PREFIX ?= /usr/local
CC ?= gcc

CFLAGS += -Wall -Wextra -pedantic -std=c99
CFLAGS += `pkg-config --cflags opencv`
LDFLAGS += `pkg-config --libs opencv`

all: findimage

findimage: findimage.c unused.h
	${CC} ${CFLAGS} $< -o $@ ${LDFLAGS}

install: findimage findimage.1
	install -D -m755 findimage ${DESTDIR}${PREFIX}/bin/findimage
	install -D -m644 findimage.1 ${DESTDIR}${PREFIX}/share/man/man1/findimage.1

clean:
	rm -f findimage
