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

  preStartPF = ''
  '';

  server = { lib, pkgs, ...}: {
    options = {
      server_address = mkOption {
        type = types.str;
        default = "router.eu.thethings.network";
        description = "Address";
      };
      serv_type = mkOption {
        type = types.str;
        default = "ttn";
        description = "server type";
      };
      serv_gw_id = mkOption {
        type = types.str;
        description = "gateway name from console";
      };
      serv_gw_key = mkOption {
        type = types.str;
        description = "gateway secret key from console";
      };
      serv_enabled = mkOption {
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
        example = "0000000000000000";
      };
      latitude = mkOption {
        type = types.nullOr types.float;
        default = 10.0;
        description = "Gateway latitude";
      };
      longitude = mkOption {
        type = types.nullOr types.float;
        default = 20.0;
        description = "Gateway longitude";
      };
      altitude = mkOption {
        type = types.nullOr types.float;
        default = 1.0;
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
        cp ${pkgs.packet_forwarder.src}/mp_pkt_fwd/global_conf.json ${baseDir}/
        cp ${mkLocalConf cfg} ${baseDir}/local_conf.json
      '';

      restartIfChanged = true;

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.runtimeShell} -c \"cd ${baseDir};${pkgs.packet_forwarder}/bin/mp_pkt_fwd\"";
        # WorkingDirectory breaks preStart even with PermissionsStartOnly
        Restart = "always";
        RestartSec = 3;
      };
    };
  };
}

