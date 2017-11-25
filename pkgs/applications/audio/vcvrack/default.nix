{ stdenv, fetchFromGitHub, cmake, pkgconfig, curl, glew, glfw, libzip, jansson
, nanovg, nanosvg, blendish, osdialog
, rtaudio , rtmidi , libsamplerate , gtk2 }:

stdenv.mkDerivation rec {
  name = "vcvrack-${version}";
  version = "v0.5.0";

  enableParallelBuilding = true;

  src = fetchFromGitHub {
    owner = "VCVRack";
    repo = "Rack";
    rev = version;
    sha256 = "0wcmzzsimkwvhs8rl2p48izjc4v78nl223bqwcv7nii9w40w5bwp";
  };

  plugins = fetchFromGitHub {
    owner = "VCVRack";
    repo = "Fundamental";
    #rev = version;
    rev = "b6a321a8ad47e158717bd475a87d15126299c6b3";
    sha256 = "0s00sm6zg5pdnsjcr3r5l5y7r06lldvsmzn6kw8yn5nmfzasp7yy";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ glew glfw curl gtk2 libzip rtaudio rtmidi libsamplerate jansson blendish nanovg nanosvg ];

  patchPhase = ''
    for file in `grep -r -l 'ext/nanovg'`
      do
        sed -i 's|../ext/nanovg/src/|${nanovg}/src/|g' $file
      done
    for file in `grep -r -l 'ext/nanosvg'`
      do
        sed -i 's|../ext/nanosvg/src/|${nanosvg}/src/|g' $file
      done 
    for file in `grep -r -l 'ext/oui-blendish'`
      do
        sed -i 's|../ext/oui-blendish/|${blendish}/include/|g' $file
      done
    for file in `grep -r -l 'ext/osdialog'`
      do
        sed -i 's|../ext/osdialog/|${osdialog}/src/|g' $file
      done

    sed -i 's|ext/nanovg/src/|${nanovg}/src/|g' Makefile
    sed -i 's|ext/osdialog/|${osdialog}/src/|g' Makefile
  '';

  buildPhase = ''
    make
    mkdir plugins/Fundamental/
    cp -R ${plugins}/* plugins/Fundamental/
    make -C plugins/Fundamental dist
  '';
  installPhase = ''
    ls .
    mkdir -p $out/plugins
    cp Rack $out/
    cp Rack.sh $out/
    cp -R plugins/Fundamental/dist/Fundamental $out/plugins/
  '';

  meta = with stdenv.lib; {
    description = "Open-source virtual modular synthesizer";
    homepage = https://vcvrack.com/;
    license = licenses.bsd3;
    maintainers = [ maintainers.sorki ];
    platforms = platforms.linux;
  };
}

