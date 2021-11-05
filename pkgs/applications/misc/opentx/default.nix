{ lib, mkDerivation, fetchFromGitHub
, cmake, gcc-arm-embedded, python3Packages
, qtbase, qtmultimedia, qttranslations, SDL, gtest
, dfu-util, avrdude
}:

mkDerivation rec {
  pname = "edgetx";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "edgetx";
    repo = "edgetx";
    rev = "v2.5.0";
    sha256 = "1jbi5r2adinczgyi89cxm0rg43shklz90r0z99vz3p5504i2bk2m";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ cmake gcc-arm-embedded python3Packages.pillow ];

  buildInputs = [ qtbase qtmultimedia qttranslations SDL ];

  postPatch = ''
    sed -i companion/src/burnconfigdialog.cpp \
      -e 's|/usr/.*bin/dfu-util|${dfu-util}/bin/dfu-util|' \
      -e 's|/usr/.*bin/avrdude|${avrdude}/bin/avrdude|'
  '';

  cmakeFlags = [
    "-DGTEST_ROOT=${gtest.src}/googletest"
    "-DQT_TRANSLATIONS_DIR=${qttranslations}/translations"
    # XXX I would prefer to include these here, though we will need to file a bug upstream to get that changed.
    #"-DDFU_UTIL_PATH=${dfu-util}/bin/dfu-util"
    #"-DAVRDUDE_PATH=${avrdude}/bin/avrdude"
  ];

  meta = with lib; {
    description = "EdgeTX Companion transmitter support software";
    longDescription = ''
      EdgeTX Companion is used for many different tasks like loading EdgeTX
      firmware to the radio, backing up model settings, editing settings and
      running radio simulators.
    '';
    homepage = "https://www.edgetx.org/";
    license = licenses.gpl2Only;
    platforms = [ "i686-linux" "x86_64-linux" "aarch64-linux" ];
    maintainers = with maintainers; [ elitak lopsided98 ];
  };

}
