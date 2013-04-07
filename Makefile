.PHONY: all install clean

PREFIX ?= /usr/local
CC ?= gcc

CFLAGS += -Wall -Wextra -pedantic -std=c99
CFLAGS += `pkg-config --cflags opencv`
LDFLAGS += `pkg-config --libs opencv`

all: findimage

findimage: findimage.c unused.h
	${CC} ${CFLAGS} $< -o $@ ${LDFLAGS}

install: all
	install -D -m755 findimage ${DESTDIR}${PREFIX}/bin/findimage

clean:
	rm -f findimage
