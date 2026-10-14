{ config, pkgs, zen-browser, ... }:

{
  home.stateVersion = "26.05";

  xdg.configFile."umbriel/config.toml".source = ./umbriel-config.toml;

  home.packages = [
    zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
