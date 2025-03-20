{ lib, stdenv, fetchFromGitHub, file, openssl, mlton
, mariadb-connector-c, postgresql, sqlite, gcc, icu, autoconf, automake, libtool
}:

stdenv.mkDerivation rec {
  pname = "urweb";
  version = "20200209";

  src = fetchFromGitHub {
    owner = "urweb";
    repo = "urweb";
    rev = "55a881f";
    hash = "sha256-V39MLf8Y+o5PLaQXNkG0tDcMsxL/AiQmcbE40swUxaQ=";
  };

  buildInputs = [ openssl mlton mariadb-connector-c postgresql sqlite icu autoconf automake libtool];

  prePatch = ''
    sed -e 's@/usr/bin/file@${file}/bin/file@g' -i configure.ac
  '';

  # patches = [
	# 	patches/postgres_disable_integrity_check.patch
	# 	patches/mysql-disable-integrity-check.uw.patch
	# 	patches/mysql-distinct-from.uw.patch
	# 	patches/mysql-my_bool.uw.patch
	# 	patches/urweb_int_field_nm.patch
	# 	patches/void.uw.patch
  # ];

  configureFlags = [ "--with-openssl=${openssl.dev}" ];

  preConfigure = ''
    export MSHEADER="${mariadb-connector-c.dev}/include/mysql/mysql.h";
    export SQHEADER="${sqlite.dev}/include/sqlite3.h";
    export PGHEADER="${postgresql.dev}/include/libpq-fe.h";
    export ICU_INCLUDES="-I${icu.dev}/include";

    export CC="${gcc}/bin/gcc";
    export CCARGS="-I$out/include \
                   -L${lib.getLib openssl}/lib \
                   -L${mariadb-connector-c}/lib/mysql \
                   -L${postgresql.lib}/lib \
                   -L${sqlite.out}/lib";
    ./autogen.sh
  '';                   #  -fsanitize=address";

  env.NIX_CFLAGS_COMPILE = toString [
    # Needed with GCC 12
    "-Wno-error=use-after-free"
  ];

  # Be sure to keep the statically linked libraries
  dontDisableStatic = true;

  # buildPhase = "make";

  # installPhase = "
  #   cp ${application}.exe $out/${application}.exe
  # ";

  meta = {
    description = "Advanced purely-functional web programming language";
    mainProgram = "urweb";
    homepage    = "http://www.impredicative.com/ur/";
    license     = lib.licenses.bsd3;
    platforms   = lib.platforms.linux ++ lib.platforms.darwin;
    maintainers = [ lib.maintainers.thoughtpolice lib.maintainers.sheganinans ];
  };
}
