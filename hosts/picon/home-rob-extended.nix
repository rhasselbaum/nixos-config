# Home Manager config for rob
{ config, pkgs, inputs, ... }:
{
  # Snapcast
  programs.snapcast-caprica = {
    enable = true;
    soundcard = "Headphones";
    latency = 125;
  };
  # Link/unlink Pipewire default audio output device monitor to Snapcast.
  home.file.".mqtt-launcher/launcher.conf.d/20-topics".text = ''
    topiclist = {
        # topic                     payload value       program & arguments
        "home-audio/snapcast/downstairs/stream-control": {
          "start": [ 'systemctl', '--user', 'start', 'snapcast-caprica.service' ],
          "stop": [ 'systemctl', '--user', 'stop', 'snapcast-caprica.service' ],
        },
        "home-audio/snapcast/kitchen/stream-control": {
          "start": [ 'systemctl', '--user', 'start', 'snapcast-caprica.service' ],
          "stop": [ 'systemctl', '--user', 'stop', 'snapcast-caprica.service' ],
        },
    }
  '';
}
