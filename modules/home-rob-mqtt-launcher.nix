# Common mqtt-launcher config
{ config, pkgs, inputs, osConfig, ... }:
let
  home-dir = "/home/rob";
  conf-dir = "${home-dir}/.mqtt-launcher";
  main-conf-file = "${conf-dir}/launcher.conf";
in
{
  # On new systems, you need to create ${conf-dir/launcher.conf.d/10-password with broker password.
  # Obviously not including that here.
  home.file.${main-conf-file}.text = ''
    logfile         = None
    mqtt_broker     = 'homeassistant.hasselbaum.net'
    mqtt_port       = 8883
    mqtt_clientid   = '${osConfig.networking.hostName}'
    mqtt_username   = 'mqtt'
    mqtt_tls        = True
    mqtt_tls_verify = True
    mqtt_tls_ca     = '${conf-dir}/home-assistant-ca.pem'
    mqtt_transport_type = 'tcp'         # alternative: 'websocket', default: 'tcp'

    topiclist = {

        # topic                     payload value       program & arguments
        "prog/pwd"          :   {
                                    None            :   [ 'pwd' ],
                                },
    }
  '';

  # CA Cert
  home.file."${conf-dir}/home-assistant-ca.pem".text = ''
    -----BEGIN CERTIFICATE-----
    MIIDtTCCAp2gAwIBAgIUALmv8HB2QLN0V/K6Wf5vSShsgbMwDQYJKoZIhvcNAQEL
    BQAwajELMAkGA1UEBhMCVVMxFjAUBgNVBAgMDU1hc3NhY2h1c2V0dHMxITAfBgNV
    BAoMGEludGVybmV0IFdpZGdpdHMgUHR5IEx0ZDEgMB4GA1UEAwwXSG9tZSBBc3Np
    c3RhbnQgTG9jYWwgQ0EwHhcNMjExMjI3MTcxMTIwWhcNMzExMjI1MTcxMTIwWjBq
    MQswCQYDVQQGEwJVUzEWMBQGA1UECAwNTWFzc2FjaHVzZXR0czEhMB8GA1UECgwY
    SW50ZXJuZXQgV2lkZ2l0cyBQdHkgTHRkMSAwHgYDVQQDDBdIb21lIEFzc2lzdGFu
    dCBMb2NhbCBDQTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBANa9XYKX
    gdASB4gi4BP1ZZKlCUjQ5aWy+5iezu/NzNSAtYBL9VayOHW5dElHlg2x3mMC2dZ7
    hJ4dCGqVYoGC+oKjeiKFooGnYCyWQnTBeGreHMJ8MkP2kAmR2uX1AckMf92C/Se1
    MiG51kXEM4uhWPJSjaJCWRf7/nd6UJo6WUR2NszSNYUH77x4V0Qty4RAJkMDgMuK
    F/z+XnK+cKp/AFonalMpO9CvQl/HGV0BlJVMIaJi+53ph5WE1e0F5cNBbhWOcqY1
    ZQZ1agxaQySXROttbDlUWh5IPm/UgEl4cijUoqG0TXJ8Sdjq9mV8Ox7HQGx+HEsC
    siyclSpEqt2QEI8CAwEAAaNTMFEwHQYDVR0OBBYEFIL8OkqBUQZZumUB8ix6dz4a
    YzITMB8GA1UdIwQYMBaAFIL8OkqBUQZZumUB8ix6dz4aYzITMA8GA1UdEwEB/wQF
    MAMBAf8wDQYJKoZIhvcNAQELBQADggEBAL1GZGJktHPgxKJfPq1OuEyNK/wtJkL2
    WphNL3OOf7mK2WqajRspQ5RVPnFWXIhjhXKA7yIJqvLt+mxsCdJw/U6SodY7te4i
    sby2T4E1MmBpmB76AQxDjz38rlS7pEoUwPC8DtXT4rNU+P7Jc/0RwGmBi3u952j6
    whTPEuO+zffNPT/8Ye3/ztt5rr0P/b0vZi9hbl6C0bB2VQ6vKyGtrcxMEvzMfuXo
    zeBeKwKk+Q8KDf2dvGQWE8y8DYfi7yvmxZIKPXlUf+3be6q/vxIgi5CxfbUxee9d
    NxFpByt4033RdWpquqPEgb4dWL5JJW3CjgFBnOrgaJbuP4cnBrcpRCs=
    -----END CERTIFICATE-----
  '';

  # User systemd units
  systemd.user.services.mqtt-launcher = {
    Unit = {
      Description = "MQTT command launcher";
      After = "network.target";
    };
    Service = {
      Type = "exec";
      Environment = "MQTTLAUNCHERCONFIG=${main-conf-file}";
      ExecStart = "${inputs.mqtt-launcher.defaultPackage.${pkgs.system}}/bin/mqtt-launcher";
      Restart= "always";
    };
    Install = {
      WantedBy = [ "network.target" ];
    };
  };
}
