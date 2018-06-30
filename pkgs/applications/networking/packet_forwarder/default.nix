{ stdenv, fetchFromGitHub
, pkgconfig
, protobufc
, lora_gateway
, paho-mqtt-embedded
, ttn-gateway-connector }:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "packet_forwarder-${version}";
  version = "4.0.1";

  src = fetchFromGitHub {
    owner = "kersing";
    repo = "packet_forwarder";
    rev = "6e523fffc7c2a1a2ef8c05eb72432d964d093e90";
    sha256 = "0jp24vi2hnqvny05px158sisp47rv1xvscq60z8h60n0lx9k89fr";
  };

  buildInputs = [ pkgconfig protobufc ];

  makeFlags = [ "CFG_SPI=native"
                "LGW_PATH=${lora_gateway.dev}" ];

  preConfigure = ''
    sed -i -e 's|-I../../ttn-gateway-connector/src|-I${ttn-gateway-connector.src}/src|g' \
      -e 's|-I../../protobuf-c|-I${protobufc}/include|g' \
      -e 's|-L../../paho.mqtt.embedded-c/build/output|-L${paho-mqtt-embedded}/lib/|g' \
      -e 's|-L../../ttn-gateway-connector/bin|-L${ttn-gateway-connector}|g' \
      mp_pkt_fwd/Makefile
  '';

  #      -e 's|-lpaho-embed-mqtt3c||g' \
  #      -e 's|-lttn-gateway-connector||g' \

  installPhase = ''
    mkdir -p $out/bin
    cp *_pkt_fwd/*_pkt_fwd $out/bin/
    #cp util_*/util_* $out/bin/
  '';

  meta = with stdenv.lib; {
    description = "A LoRa packet forwarder";
    homepage = https://github.com/Lora-net/packet_forwarder;
    maintainers = with maintainers; [ sorki ];
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}
