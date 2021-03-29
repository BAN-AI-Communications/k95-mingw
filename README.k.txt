Building zlib, openssl, and Kermit 95 using mingw32-gcc
Jacob Thompson <jakethompson1@gmail.com>

This has been tested on Fedora 18 with mingw32-gcc installed.
On that system, from the k95 directory, run:
 make CROSS_COMPILE=i686-w64-mingw32-
The resulting libraries and executables are placed in bin.

No other build environments have been tested.  Other Linux systems are likely
to work.  Windows will require mingw32, MSYS, and perl, and possibly other
tools to build OpenSSL and zlib.

Currently this builds only the Console version.  There is no reason that the
GUI version should not also be able to build with additional work.

XYZmodem, SSH, and SRP are broken, and the source code required for these
is missing.

Kerberos is broken, and I have not identified whether the libraries needed are
publicly available.

SSL is working and tested.  zlib is working but not tested.

