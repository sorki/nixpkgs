{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.networking.packet_forwarder;
  # Get a submodule without any embedded metadata:
  _filter = x: filterAttrs (k: v: k != "_module") x;
  mkLocalConf = conf:
    let
      asJSON = {
        gateway_conf = {
          gateway_ID = conf.gwid;
          servers = conf.servers;
          ref_latitude = conf.latitude;
          ref_longitude = conf.longitude;
          ref_altitude = conf.altitude;
          contact_email = conf.contact_email;
          description = conf.description;
        };
      };
    in pkgs.writeText "local_conf.json" (builtins.toJSON asJSON);

  baseDir = "/var/lib/packet_forwarder";

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
      gpioResetDelay = mkOption {
        type = types.ints.positive;
        description = "Sleep for number of seconds during reset toggle";
        default = 2;
      };
      latitude = mkOption {
        type = types.nullOr types.float;
        default = null;
        description = "Gateway latitude";
      };
      longitude = mkOption {
        type = types.nullOr types.float;
        default = null;
        description = "Gateway longitude";
      };
      altitude = mkOption {
        type = types.nullOr types.float;
        default = null;
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
        apply = x: map _filter x;
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
        D=${toString cfg.gpioResetDelay}
        output $PIN
        hi $PIN
        sleep $D
        lo $PIN
        sleep $D
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

