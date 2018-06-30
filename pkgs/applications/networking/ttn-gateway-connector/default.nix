{ stdenv, fetchFromGitHub, paho-mqtt-embedded, protobufc, pkgconfig }:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "ttn-gateway-connector-${version}";
  version = "kersing";

  src = fetchFromGitHub {
    owner = "kersing";
    repo = "ttn-gateway-connector";
    rev = "10bfae4f8a8395b28180ca525e0dd29ae201543f";
    sha256 = "1qc5cxbjp038asfx3qhqp7qxdd7v552km0vadr5pv2q27z73sklm";
  };

  outputs = [ "out" "dev" ];
  buildInputs = [ pkgconfig paho-mqtt-embedded protobufc ];

  preConfigure = ''
    sed -i 's~PAHO_SRC = .*~PAHO_SRC = ${paho-mqtt-embedded.src}~' \
      config.mk.in

    mv config.mk{.in,}

    sed -i -e 's~$(SRCDIR)/../$(PAHO_SRC)/~$(SRCDIR)/~g' \
      -e 's~$(PAHO_SRC)/build/output~${paho-mqtt-embedded}/lib~g' \
      -e 's~-lpaho-embed-mqtt3c -L$(PROTO_SRC)//protobuf-c~-lprotobuf-c~' \
      Makefile

    cp -R ${paho-mqtt-embedded.src}/MQTTClient-C/ ./src/

    #$(SRCDIR)/../$(PAHO_SRC)/MQTTClient-C/src/MQTTClient.c
    cat Makefile
  '';

  installPhase = ''
    mkdir -p $out
    cp bin/libttn-gateway-connector.so $out/
  #  mkdir -p $dev/lib
  #  make install prefix=$dev/
  '';

  meta = with stdenv.lib; {
    description = "Eclipse Paho MQTT C/C++ client for Embedded platforms";
    homepage = https://github.com/kersing/paho.mqtt.embedded-c;
    maintainers = with maintainers; [ sorki ];
    #license = licenses.bsd3; ??? EPL/EDL
    platforms = platforms.unix;
  };
}
