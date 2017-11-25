{ stdenv, fetchFromGitHub, cmake, pkgconfig
, supercollider, fftwFloat
}:

let optional = stdenv.lib.optional;
in

stdenv.mkDerivation rec {
  name = "supercollider-sc3-plugins-${version}";
  version = "3.8.0";


  src = fetchFromGitHub {
    owner = "supercollider";
    repo = "sc3-plugins";
    fetchSubmodules = true;
    rev = "Version-${version}";
    sha256 = "0c9j92q4f5jyyixsvr2ymfghxdwvynkq4bbs4qnbyhwd2wa2wi8g";
  };

  enableParallelBuilding = true;
  cmakeFlags = ''-DSC_PATH=${supercollider}/include/SuperCollider/'';

  nativeBuildInputs = [ cmake pkgconfig ];

  buildInputs = [ supercollider fftwFloat ];

  meta = {
    description = "Extension plugins for the SuperCollider3 audio synthesis server.";
    homepage = http://supercollider.sourceforge.net/;
    license = stdenv.lib.licenses.gpl3Plus;
    platforms = stdenv.lib.platforms.linux;
  };
}
