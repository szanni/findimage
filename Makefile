.PHONY: all install dist clean

PACKAGE = findimage
VERSION = 0.0.0
DIST = Makefile ${PACKAGE}.cpp ${PACKAGE}.1 unused.h LICENSE CHANGELOG

PREFIX ?= /usr/local
CXX ?= g++

CXXFLAGS += -Wall -Wextra -pedantic
CXXFLAGS += `pkg-config --cflags 'opencv4 >= 4.0'`
#LDFLAGS += `pkg-config --libs 'opencv4 >= 4.0'`
# Can not use pkg-config --libs here as it pulls in all optional dependencies, too.
LDFLAGS += -lIlmImf -lopencv_highgui -lopencv_imgcodecs -lopencv_imgproc -lopencv_core

all: ${PACKAGE}

${PACKAGE}: ${PACKAGE}.cpp unused.h
	${CXX} $< -o $@ ${CXXFLAGS} ${LDFLAGS}

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
