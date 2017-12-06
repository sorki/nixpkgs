{ stdenv, fetchFromGitHub, fetchurl, fetchpatch, autoreconfHook, pkgconfig, perl, docbook2x
, docbook_xml_dtd_45, python3Packages

# Optional Dependencies
, libapparmor ? null, gnutls ? null, libselinux ? null, libseccomp ? null
, cgmanager ? null, libnih ? null, dbus ? null, libcap ? null, systemd ? null
}:

let
  enableCgmanager = cgmanager != null && libnih != null && dbus != null;
in
with stdenv.lib;
stdenv.mkDerivation rec {
  name = "lxc-${version}";
  version = "2.1.0";

  #src = fetchurl {
  #  url = "https://linuxcontainers.org/downloads/lxc/lxc-${version}.tar.gz";
  #  sha256 = "1qld0gi19mximxm0qyr6vzav32gymhc7fvp0bzwv37j0b8q0fi1r";
  #};

  src = fetchFromGitHub {
    owner = "aither64";
    repo = "lxc";
    rev = "1481f1145635be19867736c453820e0b0fd44b30";
    sha256 = "1y5lszmp438012rz4awl2k435flsa3dzsfvc4ld2df64vyhj8dk6";
  };

  nativeBuildInputs = [
    autoreconfHook pkgconfig perl docbook2x python3Packages.wrapPython
  ];
  buildInputs = [
    libapparmor gnutls libselinux libseccomp cgmanager libnih dbus libcap
    python3Packages.python python3Packages.setuptools systemd
  ];

  patches = [
    ./support-db2x.patch
    # Fix build error against glibc 2.26
    # aither: appears to be in conflict with lxc.hook.start-host patch, doesn't seem
    #   to be needed.
    #(fetchpatch {
    #  url = "https://github.com/lxc/lxc/commit/"
    #      + "180c477a326ce85632249ff16990e8c29db1b6fa.patch";
    #  sha256 = "05jkiiixxk9ibj1fwzmy56rkkign28bd9mrmgiz12g92r2qahm2z";
    #})
    # Call lxc.net.[i].script.up hook for non-root unprivileged CTs
    #(fetchpatch {
    #  url = "https://github.com/aither64/lxc/commit/"
    #      + "f4e86dfad30099bae3ab093b81d147280996d29e.patch";
    #  sha256 = "0ilc79c5rjhivzryb8lz4y0ifhxcjvlbzvd7gmjpq93b87pp278f";
    #})
    # Add lxc.hook.start-host
    #(fetchpatch {
    #  url = "https://github.com/aither64/lxc/commit/"
    #      + "1481f1145635be19867736c453820e0b0fd44b30.patch";
    #  sha256 = "1dxajawqnr6qskcimsqjfp9lny22873pj25znnmq684lhkcimpl4";
    #})
  ];

  postPatch = ''
    sed -i '/chmod u+s/d' src/lxc/Makefile.am
  '';

  XML_CATALOG_FILES = "${docbook_xml_dtd_45}/xml/dtd/docbook/catalog.xml";

  # FIXME
  # glibc 2.25 moved major()/minor() to <sys/sysmacros.h>.
  # this commit should detect this: https://github.com/lxc/lxc/pull/1388/commits/af6824fce9c9536fbcabef8d5547f6c486f55fdf
  # However autotools checks if mkdev is still defined in <sys/types.h> runs before
  # checking if major()/minor() is defined there. The mkdev check succeeds with
  # a warning and the check which should set MAJOR_IN_SYSMACROS is skipped.
  NIX_CFLAGS_COMPILE = [ "-DMAJOR_IN_SYSMACROS" ];

  configureFlags = [
    "--localstatedir=/var"
    "--sysconfdir=/etc"
    "--disable-api-docs"
    "--with-init-script=none"
    "--with-distro=nixos" # just to be sure it is "unknown"
  ] ++ optional (libapparmor != null) "--enable-apparmor"
    ++ optional (libselinux != null) "--enable-selinux"
    ++ optional (libseccomp != null) "--enable-seccomp"
    ++ optional (libcap != null) "--enable-capabilities"
    ++ [
    "--disable-examples"
    "--enable-python"
    "--disable-lua"
    "--enable-bash"
    (if doCheck then "--enable-tests" else "--disable-tests")
    "--with-rootfs-path=/var/lib/lxc/rootfs"
  ];

  doCheck = false;

  installFlags = [
    "localstatedir=\${TMPDIR}"
    "sysconfdir=\${out}/etc"
    "sysconfigdir=\${out}/etc/default"
    "bashcompdir=\${out}/share/bash-completion/completions"
    "READMEdir=\${TMPDIR}/var/lib/lxc/rootfs"
    "LXCPATH=\${TMPDIR}/var/lib/lxc"
  ];

  postInstall = ''
    wrapPythonPrograms
  '';

  meta = {
    homepage = https://linuxcontainers.org/;
    description = "Userspace tools for Linux Containers, a lightweight virtualization system";
    license = licenses.lgpl21Plus;

    longDescription = ''
      LXC is the userspace control package for Linux Containers, a
      lightweight virtual system mechanism sometimes described as
      "chroot on steroids". LXC builds up from chroot to implement
      complete virtual systems, adding resource management and isolation
      mechanisms to Linux’s existing process management infrastructure.
    '';

    platforms = platforms.linux;
    maintainers = with maintainers; [ wkennington globin fpletz ];
  };
}
