{ stdenv, fetchFromGitHub }:

let
  rev = "591207f";
in
stdenv.mkDerivation {
  name = "ail_gpio-${rev}";
  src = fetchFromGitHub {
    owner = "sorki";
    repo = "ail_gpio";
    inherit rev;
    sha256 = "0ra60djz471biw0khqs29d3f953bmhasscp900z6vir1sadqbvc6";
  };

  installPhase = ''
    mkdir -p $out
    cp ail_gpio $out/
    cp README.rst $out/
  '';

  meta = with stdenv.lib; {
    description = "Small bash wrapper over kernels GPIO sysfs interface";
    homepage = "https://github.com/sorki/ail_gpio";
    license = licenses.wtfpl;
    maintainers = with maintainers; [ sorki ];
    platforms = platforms.linux;
  };
}
