k95_all: k95_extract k95_prepare k95_build 

k95_extract: k95source.zip
	mkdir src
	(cd src && unzip ../k95source.zip)

k95_clean:
	make -C src clean

k95_mrproper:
	rm -rf src
	rm -f bin/k95.exe bin/k95crypt.dll

k95_prepare:
	# Fix (FARPROC) issues
	(cd src && patch -p1 < ../patches/farproc.patch)
	# Fix other issues
	(cd src && patch -p1 < ../patches/jwt.patch)

k95_build: 
	make -C src

