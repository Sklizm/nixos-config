{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # ════════════════════════════════════════════════════════════
  #  NIX
  # ════════════════════════════════════════════════════════════

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    # CachyOS kernel binary cache
    substituters = [ "https://attic.xuyh0120.win/lantian" ];
    trusted-public-keys = [ "lantian:EeAUQ+W+6r7EtwnmYjeVwx5kOGEBpjlBfPlzGlTNvHc=" ];
  };

  # Automatic cleanup
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;


  # ════════════════════════════════════════════════════════════
  #  BOOT & KERNEL
  # ════════════════════════════════════════════════════════════

  boot.loader = {
    timeout = 10;
    efi.canTouchEfiVariables = true;

    systemd-boot = {
      enable = true;
      configurationLimit = 3;
      consoleMode = "max";
      editor = false; # disable the 'e' key (root-access hole with physical access)
    };
  };

  boot.kernelPackages = pkgs.cachyosKernels.linuxPackages-cachyos-latest-x86_64-v3;


  # ════════════════════════════════════════════════════════════
  #  HARDWARE
  # ════════════════════════════════════════════════════════════

  # ── GPU (NVIDIA) ────────────────────────────────────────────
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    open = true;
    modesetting.enable = true;
  };

  # ── Audio (PipeWire) ────────────────────────────────────────
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # jack.enable = true;
  };

  # ── Printing (Canon) ────────────────────────────────────────
  services.printing = {
    enable = true;
    drivers = [ pkgs.canon-cups-ufr2 ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Printer driver workaround - not fixed yet, consider a Nix-native driver
  systemd.tmpfiles.rules = [
    "d /usr/share 0755 root root -"
    "L+ /usr/share/cnpkbidir - - - - ${pkgs.canon-cups-ufr2}/share/cnpkbidir"
    "L+ /usr/share/caepcm - - - - ${pkgs.canon-cups-ufr2}/share/caepcm"
  ];


  # ════════════════════════════════════════════════════════════
  #  STORAGE
  # ════════════════════════════════════════════════════════════

  # 1TB NVMe
  fileSystems."/mnt/NVME" = {
    device = "/dev/disk/by-uuid/63a7bcb3-0d5c-4c05-b1a5-f2290c0c4e78";
    fsType = "ext4";
    options = [ "noatime" "nofail" ];
  };

  # SATA SSD
  fileSystems."/mnt/SSD" = {
    device = "/dev/disk/by-uuid/16706eda-27c2-4f85-b769-3b615d5c18d1";
    fsType = "ext4";
    options = [ "noatime" "nofail" ];
  };


  # ════════════════════════════════════════════════════════════
  #  NETWORKING
  # ════════════════════════════════════════════════════════════

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;


  # ════════════════════════════════════════════════════════════
  #  LOCALE & KEYBOARD
  # ════════════════════════════════════════════════════════════

  time.timeZone = "Europe/Chisinau";
  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };


  # ════════════════════════════════════════════════════════════
  #  USERS
  # ════════════════════════════════════════════════════════════

  users.users."codrin-nix" = {
    isNormalUser = true;
    description = "Codrin";
    extraGroups = [ "networkmanager" "wheel" ];
  };

  users.defaultUserShell = pkgs.zsh;


  # ════════════════════════════════════════════════════════════
  #  DESKTOP
  # ════════════════════════════════════════════════════════════

  programs.umbriel.enable = true;
  programs.noctalia.enable = true;

  services.displayManager.noctalia-greeter = {
    enable = true;
    settings.keyboard = {
      layout = "us,ro,ru";
      options = "grp:alt_shift_toggle";
    };
  };

  services.desktopManager.gnome.enable = true;

  environment.sessionVariables = {
    EDITOR = "micro";
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "20";
  };

  fonts.packages = with pkgs; [
    geist-font
    nerd-fonts.geist-mono
  ];


  # ════════════════════════════════════════════════════════════
  #  SHELL
  # ════════════════════════════════════════════════════════════

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    autosuggestions = {
      enable = true;
      strategy = [ "history" "completion" ];
    };

    histSize = 10000;
    histFile = "$HOME/.zsh_history";

    setOptions = [
      "HIST_IGNORE_DUPS"
      "SHARE_HISTORY"
      "HIST_FCNTL_LOCK"
      "AUTO_CD"
      "INTERACTIVE_COMMENTS"
    ];

    interactiveShellInit = ''
      eval "$(fzf --zsh)"
    '';

    shellAliases = {
      # Navigation
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      c = "clear";

      # Better listing
      ls = "eza --icons=auto";
      ll = "eza -lah --icons=auto --group-directories-first";
      la = "eza -a --icons=auto";
      tree = "eza --tree --icons=auto";

      # File viewing and search
      cat = "bat";
      grep = "rg";

      # NixOS
      rebuild = "sudo nixos-rebuild switch --flake ~/nixos#nixos";
      update = "nix flake update ~/nixos";

      # Utilities
      df = "df -h";
      free = "free -h";
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    fuzzyCompletion = true;
    keybindings = true;
  };


  # ════════════════════════════════════════════════════════════
  #  APPS & GAMING
  # ════════════════════════════════════════════════════════════

  programs.firefox.enable = true;

  programs.steam = {
    enable = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  programs.gamemode.enable = true;


  # ════════════════════════════════════════════════════════════
  #  SYSTEM PACKAGES
  # ════════════════════════════════════════════════════════════

  environment.systemPackages = with pkgs; [
    # ── CLI tools ──
    git
    lazygit
    btop
    fastfetch
    ripgrep
    fd
    bat
    eza
    glow
    yazi
    micro
    kitty

    # ── Archives ──
    ark
    unzip
    p7zip

    # ── Media ──
    mpv
    imv
    zathura
    cava
    easyeffects
    tauon

    # ── Screenshots ──
    grim
    slurp

    # ── Internet & chat ──
    discord
    telegram-desktop
    qbittorrent

    # ── Office ──
    libreoffice-qt

    # ── Gaming ──
    heroic
    mangohud

    # ── Theming ──
    bibata-cursors
  ];


  # ════════════════════════════════════════════════════════════
  #  DO NOT CHANGE (see `man configuration.nix`)
  # ════════════════════════════════════════════════════════════

  system.stateVersion = "26.05";
}
