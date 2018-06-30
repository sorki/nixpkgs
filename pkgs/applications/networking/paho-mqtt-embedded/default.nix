{ stdenv, fetchFromGitHub }:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "paho.mqtt.embedded-c-${version}";
  version = "kersing";

  src = fetchFromGitHub {
    owner = "kersing";
    repo = "paho.mqtt.embedded-c";
    rev = "e4e0402ae16985a1b83d77dab26e65532bed4174";
    sha256 = "0cf1hlqjj8f3xavxy3m3s4lh87dm69rmyf3a5rsr2rk8cb004d4c";
  };

  preConfigure = ''
    sed -i /ldconfig/d Makefile
  '';

  installPhase = ''
    mkdir -p $out/lib
    make install prefix=$out/
    pushd $out/lib
    rm libpaho-embed-mqtt3c.so
    ln -s libpaho-embed-mqtt3c.so.1.0 libpaho-embed-mqtt3c.so
    ln -s libpaho-embed-mqtt3c.so.1.0 libpaho-embed-mqtt3c.so.1
    popd
  '';

  meta = with stdenv.lib; {
    description = "Eclipse Paho MQTT C/C++ client for Embedded platforms";
    homepage = https://github.com/kersing/paho.mqtt.embedded-c;
    maintainers = with maintainers; [ sorki ];
    #license = licenses.bsd3; ??? EPL/EDL
    platforms = platforms.unix;
  };
}
