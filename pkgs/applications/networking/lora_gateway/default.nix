{ stdenv, fetchFromGitHub
, gwPlatform ? "lorank"
}:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "lora_gateway-${version}";
  version = "5.0.1";

  src = fetchFromGitHub {
    owner = "TheThingsNetwork";
    repo = "lora_gateway";
    rev = "f4329a63a08fb643d1e05815529f8be1461b7dd9";
    sha256 = "0i5ayvw7gzczf6pdih4xlqxi4n8dl7s0fjssjfni181x6jd3y5s8";
  };

  outputs = [ "out" "dev" ];

  preConfigure = ''
    sed -i 's~PLATFORM= kerlink~PLATFORM= ${gwPlatform}~' libloragw/library.cfg
    sed -i 's~/dev/spidev1.0~/dev/spidev0.0~' libloragw/inc/lorank.h
  '';

  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $dev/include
    cp -a libloragw $dev/include/
    cp */util_* $out/bin
  '';

  meta = with stdenv.lib; {
    description = "Driver for SX1301 based gateways";
    homepage = https://github.com/Lora-net/lora_gateway;
    maintainers = with maintainers; [ sorki ];
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}
