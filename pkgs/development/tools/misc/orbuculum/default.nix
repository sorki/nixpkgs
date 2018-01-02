{ stdenv, libelf, libusb1, libftdi1, libbfd, libiberty, zlib, bash, git, fetchgit }:
stdenv.mkDerivation {
  name = "orbuculum";
  src = fetchgit {
    url = "git://github.com/mubes/orbuculum.git";
    rev = "8b357b19280c26fb94a717c5001efc1401de8acc";
    sha256 = "0wzxjdi1sgwx3x5bizishdsm50an81vgmnbwg5dm56lc7xii84kf";
    leaveDotGit = true;
  };

  buildInputs = [ git libelf libusb1 libftdi1 libbfd libiberty zlib ];

  postPatch = ''
    substituteInPlace Tools/git_hash_to_c/git_hash_to_c.sh --replace "/bin/bash" "${bash}/bin/bash"
  '';

  installPhase = ''
    for f in ofiles/orb*; do
      install -Dm755 $f $out/bin/$(basename $f)
    done
  '';

  meta = with stdenv.lib; {
    license = licenses.gpl3;
    description = "Cortex M SWO SWV Demux and Postprocess";
    homepage = https://github.com/mubes/orbuculum;
    maintainers = with maintainers; [ sorki ];
    platforms = platforms.linux;
  };
}
