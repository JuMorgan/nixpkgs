{ stdenv, fetchurl, cups, libssh, libXpm, nxproxy, openldap, openssh,
makeWrapper, qtbase, qtsvg, qtx11extras, qttools, phonon }:

stdenv.mkDerivation rec {
  name = "x2goclient-${version}";
  version = "4.1.2.0";

  src = fetchurl {
    url = "http://code.x2go.org/releases/source/x2goclient/${name}.tar.gz";
    sha256 = "1x1iiyszz6mbrnsqacxzclyx172djq865bw3y83ya7lc9j8a71zn";
  };

  buildInputs = [ cups libssh libXpm nxproxy openldap openssh
                  qtbase qtsvg qtx11extras qttools phonon ];
  nativeBuildInputs = [ makeWrapper ];

  patches = [ ./qt511.patch ];

  postPatch = ''
     substituteInPlace Makefile \
       --replace "SHELL=/bin/bash" "SHELL=$SHELL" \
       --replace "lrelease-qt4" "${qttools.dev}/bin/lrelease" \
       --replace "qmake-qt4" "${qtbase.dev}/bin/qmake" \
       --replace "-o root -g root" ""
  '';

  makeFlags = [ "PREFIX=$(out)" "ETCDIR=$(out)/etc" "build_client" "build_man" ];

  enableParallelBuilding = true;

  installTargets = [ "install_client" "install_man" ];
  postInstall = ''
    wrapProgram "$out/bin/x2goclient" --suffix PATH : "${nxproxy}/bin:${openssh}/libexec";
  '';

  meta = with stdenv.lib; {
    description = "Graphical NoMachine NX3 remote desktop client";
    homepage = http://x2go.org/;
    license = licenses.gpl2;
    platforms = platforms.linux;
  };
}
