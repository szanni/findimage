.PHONY: all install dist clean

PACKAGE = findimage
VERSION = 0.0.0
DIST = Makefile ${PACKAGE}.c ${PACKAGE}.1 unused.h LICENSE CHANGELOG

PREFIX ?= /usr/local
CC ?= gcc

CFLAGS += -Wall -Wextra -pedantic -std=c99
CFLAGS += `pkg-config --cflags opencv`
LDFLAGS += `pkg-config --libs opencv`

all: ${PACKAGE}

${PACKAGE}: ${PACKAGE}.c unused.h
	${CC} ${CFLAGS} $< -o $@ ${LDFLAGS}

install: ${PACKAGE} ${PACKAGE}.1
	install -D -m755 ${PACKAGE} ${DESTDIR}${PREFIX}/bin/${PACKAGE}
	install -D -m644 ${PACKAGE}.1 ${DESTDIR}${PREFIX}/share/man/man1/${PACKAGE}.1

dist: ${DIST}
	mkdir -p ${PACKAGE}-${VERSION}
	cp ${DIST} ${PACKAGE}-${VERSION}
	tar -cf ${PACKAGE}-${VERSION}.tar ${PACKAGE}-${VERSION}
	gzip -fk ${PACKAGE}-${VERSION}.tar
	xz -f ${PACKAGE}-${VERSION}.tar

clean:
	rm -f ${PACKAGE}
	rm -rf ${PACKAGE}-${VERSION}{,.tar,.tar.gz,.tar.xz}
