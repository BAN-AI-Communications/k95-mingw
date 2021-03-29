# Config
AR=$(CROSS_COMPILE)ar
AS=$(CROSS_COMPILE)as
CC=$(CROSS_COMPILE)gcc
DLLWRAP=$(CROSS_COMPILE)dllwrap
PERL=perl
RANLIB=$(CROSS_COMPILE)ranlib
TAR=tar

LDDEBUG ?= -s

# Version numbers
OPENSSL_VERSION=openssl-0.9.7

# Filename variables
OPENSSL_ASMS=$(OPENSSL_VERSION)/crypto/bn/asm/bn-win32.s \
             $(OPENSSL_VERSION)/crypto/bn/asm/co-win32.s \
             $(OPENSSL_VERSION)/crypto/des/asm/d-win32.s \
             $(OPENSSL_VERSION)/crypto/des/asm/y-win32.s \
             $(OPENSSL_VERSION)/crypto/bf/asm/b-win32.s \
             $(OPENSSL_VERSION)/crypto/cast/asm/c-win32.s \
             $(OPENSSL_VERSION)/crypto/rc4/asm/r4-win32.s \
             $(OPENSSL_VERSION)/crypto/md5/asm/m5-win32.s \
             $(OPENSSL_VERSION)/crypto/sha/asm/s1-win32.s \
             $(OPENSSL_VERSION)/crypto/ripemd/asm/rm-win32.s \
             $(OPENSSL_VERSION)/crypto/rc5/asm/r5-win32.s \

OPENSSL_MAKS=$(OPENSSL_VERSION)/MINFO \
             $(OPENSSL_VERSION)/ms/mingw32a.mak \
             $(OPENSSL_VERSION)/ms/mingw32f.mak

OPENSSL_DEFS=$(OPENSSL_VERSION)/ms/libeay32.def \
             $(OPENSSL_VERSION)/ms/ssleay32.def

OPENSSL_DLLS=bin/libeay32.dll \
             bin/ssleay32.dll

# Rules
openssl_all: openssl_extract openssl_prepare openssl_build openssl_link

openssl_extract: $(OPENSSL_VERSION).tar.gz
	$(TAR) zxf $(OPENSSL_VERSION).tar.gz

openssl_clean:
	rm -rf $(OPENSSL_VERSION)
	rm -f $(OPENSSL_DLLS)

openssl_configure: $(OPENSSL_VERSION)/Configure
	(cd $(OPENSSL_VERSION) && \
	$(PERL) Configure Mingw32 zlib no-idea no-mdc2 no-rc5 )

openssl_asm: $(OPENSSL_ASMS)

openssl_mak: $(OPENSSL_MAKS)

openssl_defs: $(OPENSSL_DEFS)

openssl_prepare: openssl_configure openssl_asm openssl_mak openssl_defs
	# Fix OCSP_RESPONSE, OCSP_REQUEST, and X509_NAME
	patch $(OPENSSL_VERSION)/crypto/ocsp/ocsp.h < patches/ocsp.patch
	patch $(OPENSSL_VERSION)/crypto/asn1/a_strex.c < patches/a_strex.patch
	# Documentation says it's ok if this fails...
	make -C $(OPENSSL_VERSION) -f ms/mingw32f.mak || true

openssl_build: 
	make -C $(OPENSSL_VERSION) -f ms/mingw32a.mak

openssl_link: $(OPENSSL_DLLS)

# Individual asms
$(OPENSSL_VERSION)/crypto/bn/asm/bn-win32.s: \
 $(OPENSSL_VERSION)/crypto/bn/asm/bn-586.pl
	(cd $(OPENSSL_VERSION)/crypto/bn/asm && \
	$(PERL) bn-586.pl gaswin > bn-win32.s)

$(OPENSSL_VERSION)/crypto/bn/asm/co-win32.s: \
 $(OPENSSL_VERSION)/crypto/bn/asm/co-586.pl
	(cd $(OPENSSL_VERSION)/crypto/bn/asm && \
	$(PERL) co-586.pl gaswin > co-win32.s)

$(OPENSSL_VERSION)/crypto/des/asm/d-win32.s: \
 $(OPENSSL_VERSION)/crypto/des/asm/des-586.pl
	(cd $(OPENSSL_VERSION)/crypto/des/asm && \
	$(PERL) des-586.pl gaswin > d-win32.s)

$(OPENSSL_VERSION)/crypto/des/asm/y-win32.s: \
 $(OPENSSL_VERSION)/crypto/des/asm/crypt586.pl
	(cd $(OPENSSL_VERSION)/crypto/des/asm && \
	$(PERL) crypt586.pl gaswin > y-win32.s)

$(OPENSSL_VERSION)/crypto/bf/asm/b-win32.s: \
 $(OPENSSL_VERSION)/crypto/bf/asm/bf-586.pl
	(cd $(OPENSSL_VERSION)/crypto/bf/asm && \
	$(PERL) bf-586.pl gaswin > b-win32.s)

$(OPENSSL_VERSION)/crypto/cast/asm/c-win32.s: \
 $(OPENSSL_VERSION)/crypto/cast/asm/cast-586.pl
	(cd $(OPENSSL_VERSION)/crypto/cast/asm && \
	$(PERL) cast-586.pl gaswin > c-win32.s)

$(OPENSSL_VERSION)/crypto/rc4/asm/r4-win32.s: \
 $(OPENSSL_VERSION)/crypto/rc4/asm/rc4-586.pl
	(cd $(OPENSSL_VERSION)/crypto/rc4/asm && \
	$(PERL) rc4-586.pl gaswin > r4-win32.s)

$(OPENSSL_VERSION)/crypto/md5/asm/m5-win32.s: \
 $(OPENSSL_VERSION)/crypto/md5/asm/md5-586.pl
	(cd $(OPENSSL_VERSION)/crypto/md5/asm && \
	$(PERL) md5-586.pl gaswin > m5-win32.s)

$(OPENSSL_VERSION)/crypto/sha/asm/s1-win32.s: \
 $(OPENSSL_VERSION)/crypto/sha/asm/sha1-586.pl
	(cd $(OPENSSL_VERSION)/crypto/sha/asm && \
	$(PERL) sha1-586.pl gaswin > s1-win32.s)

$(OPENSSL_VERSION)/crypto/ripemd/asm/rm-win32.s: \
 $(OPENSSL_VERSION)/crypto/ripemd/asm/rmd-586.pl
	(cd $(OPENSSL_VERSION)/crypto/ripemd/asm && \
	$(PERL) rmd-586.pl gaswin > rm-win32.s)

$(OPENSSL_VERSION)/crypto/rc5/asm/r5-win32.s: \
 $(OPENSSL_VERSION)/crypto/rc5/asm/rc5-586.pl
	(cd $(OPENSSL_VERSION)/crypto/rc5/asm && \
	$(PERL) rc5-586.pl gaswin > r5-win32.s)

# Individual makefiles
$(OPENSSL_VERSION)/MINFO: $(OPENSSL_VERSION)/util/mkfiles.pl
	(cd $(OPENSSL_VERSION) && perl util/mkfiles.pl > MINFO)

$(OPENSSL_VERSION)/ms/mingw32a.mak: $(OPENSSL_VERSION)/util/mk1mf.pl
	# Fix broken makefile
	(cd $(OPENSSL_VERSION) && \
	$(PERL) util/mk1mf.pl no-idea no-mdc2 no-rc5 gaswin Mingw32 | \
	sed '/^CC=/s/gcc/$(CC)/;/^CFLAG=/s/m486/march=i486/;/^CFLAG=/s|$$| -DZLIB -I'`pwd`'/../$(ZLIB_VERSION)|;/^MKDIR=/s/g//;/^ASM=/s/as/$(AS)/;/^RM=/s/rem/true/;/^RANLIB=/s/ranlib/$(RANLIB)/;/^MKLIB=/s/ar/$(AR)/;/^all:/s/exe//' \
	> ms/mingw32a.mak)

$(OPENSSL_VERSION)/ms/mingw32f.mak: $(OPENSSL_VERSION)/util/mk1mf.pl
	(cd $(OPENSSL_VERSION) && \
	$(PERL) util/mk1mf.pl no-idea no-mdc2 no-rc5 gaswin Mingw32-files \
	> ms/mingw32f.mak)

# Individual defs
$(OPENSSL_VERSION)/ms/libeay32.def: $(OPENSSL_VERSION)/util/mkdef.pl
	(cd $(OPENSSL_VERSION) && \
	$(PERL) util/mkdef.pl 32 libeay > ms/libeay32.def)

$(OPENSSL_VERSION)/ms/ssleay32.def: $(OPENSSL_VERSION)/util/mkdef.pl
	(cd $(OPENSSL_VERSION) && \
	$(PERL) util/mkdef.pl 32 ssleay > ms/ssleay32.def)

# Individual dlls
bin/libeay32.dll: $(OPENSSL_VERSION)/out/libcrypto.a \
 $(OPENSSL_VERSION)/ms/libeay32.def
	(cd $(OPENSSL_VERSION) && \
	$(DLLWRAP) --dllname ../bin/libeay32.dll --output-lib out/libeay32.a \
	--def ms/libeay32.def out/libcrypto.a -lwsock32 -lgdi32 $(LDDEBUG))

bin/ssleay32.dll: $(OPENSSL_VERSION)/out/libssl.a \
 $(OPENSSL_VERSION)/ms/ssleay32.def
	(cd $(OPENSSL_VERSION) && \
	$(DLLWRAP) --dllname ../bin/ssleay32.dll --output-lib out/ssleay32.a \
	--def ms/ssleay32.def out/libssl.a out/libeay32.a $(LDDEBUG))

