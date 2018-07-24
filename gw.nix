# To build, use:
# nix-build nixos -I nixos-config=nixos/modules/installer/cd-dvd/sd-image-armv7l-multiplatform.nix -A config.system.build.sdImage
{ config, lib, pkgs, ... }:

let
  extlinux-conf-builder =
    import <nixpkgs/nixos/modules/system/boot/loader/generic-extlinux-compatible/extlinux-conf-builder.nix> {
      inherit pkgs;
    };
in
{
  imports = [
    <nixpkgs/nixos/modules/profiles/base.nix>
#    <nixpkgs/nixos/modules/profiles/installation-device.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image.nix>
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  assertions = lib.singleton {
    assertion = pkgs.stdenv.system == "armv7l-linux";
    message = "sd-image-armv7l-multiplatform.nix can be only built natively on ARMv7; " +
      "it cannot be cross compiled";
  };

  boot.loader.timeout = -1;
  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;
  boot.loader.generic-extlinux-compatible.configurationLimit = 4;

  boot.consoleLogLevel = lib.mkDefault 7;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelPatches = [
     { name = "Enable SPI and PPS in DT";
       patch = (pkgs.fetchpatch {
         url = "https://github.com/sorki/linux/compare/master...rpi_spi_pps.patch";
         sha256 = "08aiv0fbdb1w1lnsnmrdymwpsj8j4xrq86yzv0vf3pggmb448ynq";
       });
     }
  ];

  environment.systemPackages = with pkgs; [
    git
    gpsd
    pps-tools
    packet_forwarder
    lora_gateway
    # XXX: tempo
    vim
    stdenv
    stdenvNoCC
  ];

  services.nixosManual.enable = false;
  services.openssh.enable = true;
  # XXX: temp
  #services.openssh.permitRootLogin = "yes";
  # XXX: temp
  services.mingetty.autologinUser = "root";

  networking.packet_forwarder = {
    enable = true;
    gwid = lib.mkDefault "B827EBFFFE517AAA";
    contact_email = lib.mkDefault "srk@48.io";
    description = lib.mkDefault "Test gw A";
  };

  services.journald = {
    extraConfig = ''
      Storage=volatile
    '';
  };

  services.gpsd = {
    enable = true;
    nowait = true;
    device = "/dev/ttyS1";
  };

  services.chrony = {
    enable = true;
    extraConfig = ''
      refclock PPS /dev/pps0 refid PPS
      refclock SHM 0 refid NMEA
      makestep 0.1 1

      # Allow computers on the unrouted nets to use the server.
      allow 10/8
      allow 192.168/16
      allow 172.16/12
    '';
  };

  system.nixos.stateVersion = "18.09"; 

  boot.kernelParams = ["console=tty0" "modprobe.blacklist=vc4,pps_ldisc" ];
  #boot.kernelParams = ["console=tty0" "modprobe.blacklist=vc4,pps_ldisc" ];
  # would fix vc4, but I like it the blacklist way
  # boot.kernelParams = ["cma=32M"];

  # FIXME: this probably should be in installation-device.nix
  users.extraUsers.root.initialHashedPassword = "";
  users.extraUsers.root.openssh.authorizedKeys.keys =
    [ "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBDUus8o86CftVSj2yJU0P0cCbeWIPt7x0SenQLS7cjnWoXOGWvUr1AVdPl3dAVeoE1pnDNLYxLblQ18lsmnIxfo= rmarko@grampi"
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/cLwGwE4fmH4tFLycbeCVVVn0SIxGZAEuyYk2kIzH4+mQrGiAJngGSvN10U9LU4PDj4fjIqzy6rllWoW+CJXGiU2qb5rXpOyTvQSVj8lr4fk9ZU/QC8imByAZ+yFiaaE5gLrK6azu7fF2wl//WN2sm2k54hAIMWw68gb6NZgTxj+ekXm2DMaopVJqM+TSCaB03K9Kcu/lQ6kMIw9+9DLPeJY3unRVZdX5NWo8SGrzmLse3OrInhuCeP3kVjQciLq3S9eSoA0usuBHaoiXwiNJPFiMm3wyZnMB1lfzoEEdkIq3Y8Cknpela+sl72QblT38mzui7qSp03WWlOBQIjkE4BD+Z9Tx6pLsTaRlr+msWda5nIASaUU6cXA8s/1ZUyfTFiNhPun89x9IFLgUx8V5SsmMSAvQprCwiEcNmcOegEgg2cbq5Tw5vJHx5+2zCQdjnU7OLFZww0xSFjAzTeAP5KKwZ7n7D8moRAlhW5n68Q4S4/4jBBULcXFwBmariCMe8RD1jXGA0JtKSOcaziw0iQIBhF32rxMg9ToUAyxc5Wdo481K0sRrwvINYxwFZIa5bzdGJZbiCfQrDN/OqfVl2WZ2CyPwbY2PqwkO7FoMemcWBpxaeWbIQoj2mkwWraTXblJzu7/tNfrFm5tYKzPMkCylCTRD5CvyQhFPoxGBBw== adluc"
      "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAvjg654K+GBNMHAnPs7ML79gPdwVmH2ocqK+jg6vCYNdpx9dwVdz4jeGdZu/hdsWCCRZwCk5CCTV3I//1pR396fMLIaTULD1wPh9frYLLCMgJVshmI1OtwRwKCfn6yfY1bNKIUSbg4xlKkeGJMn7CjnAi6dJJS+oiTu2GbyeA2IsV7wHt4qVVDBxW/i/85GIQiyFIJTtyuncufoUNhU/SVn/AS+MMQcRx6YsLAN11Gip8o1dy5DHuheo+NU0SczjPoIh+FlXTpjT6E+UpJLoTTyPqDY0jx19OkSYTniEqxiA/Rh5Q0f93eN0y67H+Nt2EzQyBSFWYfV24BDzI2rUHfQ== grepl@static-ip211"
 ];

  services.tor.enable = true;
  services.tor.extraConfig = ''
    HiddenServiceDir /var/lib/tor/hidden_ssh/
    HiddenServicePort 22 127.0.0.1:22
  '';

  sdImage = {
    populateBootCommands = let
      configTxt = pkgs.writeText "config.txt" ''
        # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
        # when attempting to show low-voltage or overtemperature warnings.
        avoid_warnings=1

        [pi2]
        kernel=u-boot-rpi2.bin

        [pi3]
        kernel=u-boot-rpi3.bin

        # U-Boot used to need this to work, regardless of whether UART is actually used or not.
        # TODO: check when/if this can be removed.
        enable_uart=1
        # Don't vary core freq
        core_freq=250
      '';
      in ''
        (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/boot/)
        cp ${pkgs.ubootRaspberryPi2_NoDelays}/u-boot.bin boot/u-boot-rpi2.bin
        cp ${pkgs.ubootRaspberryPi3_32bit_NoDelays}/u-boot.bin boot/u-boot-rpi3.bin
        cp ${configTxt} boot/config.txt
        ${extlinux-conf-builder} -t 3 -n no -c ${config.system.build.toplevel} -d ./boot
      '';
  };
}
