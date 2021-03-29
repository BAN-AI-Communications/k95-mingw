ZLIB_VERSION=zlib-1.2.8

all: bin zlib openssl k95

bin:
	mkdir bin

zlib: bin/zlib.dll

bin/zlib.dll:
	make -f zlib.mk CROSS_COMPILE=$(CROSS_COMPILE) \
	ZLIB_VERSION=$(ZLIB_VERSION) zlib_all

openssl: zlib bin/libeay32.dll bin/ssleay32.dll

bin/libeay32.dll:
	make -f openssl.mk CROSS_COMPILE=$(CROSS_COMPILE) \
	ZLIB_VERSION=$(ZLIB_VERSION) openssl_all

bin/ssleay32.dll: bin/libeay32.dll

k95: zlib openssl
	make -f k95.mk CROSS_COMPILE=$(CROSS_COMPILE) \
	ZLIB_VERSION=$(ZLIB_VERSION) k95_all

clean:
	make -f k95.mk k95_clean

mrproper:
	make -f zlib.mk zlib_mrproper
	make -f openssl.mk openssl_clean
	make -f k95.mk k95_mrproper
	rmdir bin

