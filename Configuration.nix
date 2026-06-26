{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  system.stateVersion = "25.11";

  # ── Boot ──────────────────────────────────────────────────────────────────
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "nvidia_drm.modeset=1" ];
  };

  # ── Networking ────────────────────────────────────────────────────────────
  networking = {
    hostName = "NixOS";
    networkmanager.enable = true;
  };

  time.timeZone = "America/Los_Angeles";

  # ── Nix ───────────────────────────────────────────────────────────────────
  nixpkgs.config.allowUnfree = true;

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # ── GPU / Hardware ────────────────────────────────────────────────────────
  hardware = {
    enableAllFirmware = true;
    bluetooth.enable = true;

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    nvidia = {
      modesetting.enable = true;
      powerManagement.enable = false;
      open = false;
      nvidiaSettings = true;
    };
  };

  # ── Display / Desktop ─────────────────────────────────────────────────────
  services.xserver = {
    enable = true;
    videoDrivers = [ "nvidia" ];
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  programs = {
    hyprland = {
      enable = true;
      withUWSM = true;
      xwayland.enable = true;
    };
    firefox.enable = true;
    zsh.enable = true;

    # gamemode library must be explicitly passed to Steam's wrapper
    gamemode.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = false;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
      package = pkgs.steam.override {
        extraPkgs = p: [ p.gamemode ];
      };
    };
  };

  # ── Fonts ─────────────────────────────────────────────────────────────────
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
  ];

  # ── Audio ─────────────────────────────────────────────────────────────────
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ── Services ──────────────────────────────────────────────────────────────
  services = {
    flatpak.enable = true;
    udisks2.enable = true;
    blueman.enable = true;
  };

  # ── Security ──────────────────────────────────────────────────────────────
  security = {
    polkit.enable = true;
    apparmor.enable = true;
    rtkit.enable = true;
  };

  # ── Virtualisation ────────────────────────────────────────────────────────
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # ── User ──────────────────────────────────────────────────────────────────
  users.users.Payton = {
    isNormalUser = true;
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "input"
    ];
    subUidRanges = [{ startUid = 100000; count = 65536; }];
    subGidRanges = [{ startGid = 100000; count = 65536; }];
  };

  # ── Packages ──────────────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    vim wget git

    distrobox podman

    ghostty kitty

    waybar wofi hyprpaper
    grimblast slurp

    kdePackages.dolphin peazip

    fastfetch geany
    spotify vesktop mullvad-browser

    lutris protonup-qt wine

    protonvpn-gui openrgb
    qbittorrent

    # lunar-client omitted — broken in nixpkgs; use Flatpak instead:
    # flatpak install com.lunarclient.LunarClient
  ];
}
