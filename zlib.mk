
zlib_all: zlib_extract zlib_build 

zlib_extract: $(ZLIB_VERSION).tar.gz
	tar zxf $(ZLIB_VERSION).tar.gz

zlib_clean:
	make -C $(ZLIB_VERSION) -f win32/Makefile.gcc clean

zlib_mrproper:
	rm -rf $(ZLIB_VERSION)
	rm -f bin/zlib.dll

zlib_build: 
	make -C $(ZLIB_VERSION) -f win32/Makefile.gcc PREFIX=$(CROSS_COMPILE) SHAREDLIB=../bin/zlib.dll

