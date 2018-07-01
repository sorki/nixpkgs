{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.networking.packet_forwarder;
  mkLocalConf = conf:
    let
      asJSON = {
        gateway_conf = {
          gateway_ID = conf.gwid;
          servers = conf.servers;
          ref_latitude = conf.latitude;
          ref_longituted = conf.longtitude;
          ref_altitude = conf.altitude;
          contact_email = conf.contact_email;
          description = conf.description;
        };
      };
    in pkgs.writeText "local_conf.json" (builtins.toJSON asJSON);

  baseDir = "/var/lib/packet_forwarder";

  preStartPF = ''
  '';

  server = { lib, pkgs, ...}: {
    options = {
      address = mkOption {
        type = types.str;
        default = "router.eu.thethings.network";
        description = "Address";
      };

      portUp = mkOption {
        type = types.ints.positive;
        default = 1700;
        description = "Up port";
      };

      portDown = mkOption {
        type = types.ints.positive;
        default = 1700;
        description = "Down port";
      };

      enabled = mkOption {
        type = types.bool;
        default = true;
        description = "Enabled server";
      };
    };
  };
in {
  options = {
    networking.packet_forwarder = {
      enable = mkEnableOption "LoRa packet forwarder";
      gwid = mkOption {
        type = types.str;
        description = "Gateway ID, usually network interface mac address without colons";
      };
      gpioResetPin = mkOption {
        type = types.ints.positive;
        description = "GPIO pin connected to IC880a reset pin";
        default = 25;
      };
      latitude = mkOption {
        type = types.nullOr types.str;
        default = "10.0";
        description = "Gateway latitude";
      };
      longtitude = mkOption {
        type = types.nullOr types.str;
        default = "20.0";
        description = "Gateway longtitude";
      };
      altitude = mkOption {
        type = types.nullOr types.str;
        default = "-1.0";
        description = "Gateway altitude";
      };
      contact_email = mkOption {
        type = types.str;
        description = "Gateway operator contact e-mail";
      };
      description = mkOption {
        type = types.nullOr types.str;
        description = "Gateway description";
        default = null;
      };
      servers = mkOption {
        type = types.listOf (types.submodule server);
        default = [ { address = "router.eu.thethings.network"; } ];
        description = "Servers to route packets to";
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.packet_forwarder = {
      description = "LoRa packet forwarder";
      after = [ "network.target" ];
      wants = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      # packet forwarders need to run in a directory containing configs
      # so we create one for them
      preStart = ''
        mkdir -p ${baseDir}
        cp ${pkgs.packet_forwarder.src}/poly_pkt_fwd/global_conf.json ${baseDir}/
        cp ${mkLocalConf cfg} ${baseDir}/local_conf.json

        source ${pkgs.ail_gpio}/ail_gpio
        PIN=${toString cfg.gpioResetPin}
        output $PIN
        hi $PIN
        sleep 1
        lo $PIN
        sleep 1
      '';

      restartIfChanged = true;

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.runtimeShell} -c \"cd ${baseDir};${pkgs.packet_forwarder}/bin/poly_pkt_fwd\"";
        # WorkingDirectory breaks preStart even with PermissionsStartOnly
        Restart = "always";
        RestartSec = 3;
      };
    };
  };
}

