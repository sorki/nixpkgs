{ stdenv, fetchFromGitHub
, gwPlatform ? "lorank"
}:

with stdenv.lib;

stdenv.mkDerivation rec {
  name = "lora_gateway-${version}";
  version = "5.0.1-kersing";

  src = fetchFromGitHub {
    owner = "kersing";
    repo = "lora_gateway";
    rev = "ce8369f6b9668d229d1e5b460e136982db8f9d9e";
    sha256 = "1726fagxhgw5spk47jkqz9d768hq9yryppnv0l5rm4ykmqhsn6p4";
  };

  outputs = [ "out" "dev" ];

  makeFlags = [ "-C libloragw" ];

  preConfigure = ''
    sed -i 's~CFG_SPI= .*~CFG_SPI= native~' libloragw/library.cfg
    sed -i 's~PLATFORM= .*~PLATFORM= ${gwPlatform}~' libloragw/library.cfg
    sed -i 's~/dev/spidev1.0~/dev/spidev0.0~' libloragw/inc/lorank.h
  '';

  installPhase = ''
    ls -lr libloragw/
    mkdir -p $out/bin
    mv libloragw/test_* $out/bin

    mkdir -p $dev/
    cp -a libloragw/* $dev/
  '';

  meta = with stdenv.lib; {
    description = "Driver for SX1301 based gateways";
    homepage = https://github.com/kersing/lora_gateway;
    maintainers = with maintainers; [ sorki ];
    license = licenses.bsd3;
    platforms = platforms.unix;
  };
}
