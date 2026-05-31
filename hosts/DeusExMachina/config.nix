# 💫 https://github.com/JaKooLit 💫 #
# Main default config
{ pkgs
, host
, username
, options
, config
, lib
, inputs
, system
, ...
}:
let
  inherit (import ./variables.nix) keyboardLayout;
in
{
  imports = [
    ./hardware.nix
    ./users.nix
    ./packages-fonts.nix
    ../../modules/amd-drivers.nix
    ../../modules/vm-guest-services.nix
    ../../modules/local-hardware-clock.nix
  ];

  # BOOT related stuff
  boot = {
    blacklistedKernelModules = [ "kvm" "kvm-amd" ];

    kernelPackages = pkgs.linuxPackages;

    kernelParams = [
      "systemd.mask=systemd-vconsole-setup.service"
      "systemd.mask=dev-tpmrm0.device"
      "nowatchdog"
      "modprobe.blacklist=sp510_tco"
      "modprobe.blacklist=iTCO_wdt"
      "amdgpu.dcdebugmask=0x10"
      "amdgpu.noretry=0"
    ];

    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "usbhid" "sd_mod" ];
      kernelModules = [ "amdgpu" "vboxdrv" "vboxnetflt" "vboxnetadp" ]; # Forceert vroege driver activatie
    };

    kernel.sysctl = {
      "vm.max_map_count" = 2147483642;
    };

    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 5;

    tmp = {
      useTmpfs = false;
      tmpfsSize = "30%";
    };

    binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };

    plymouth.enable = false;
  };

  drivers.amdgpu.enable = true;
  vm.guest-services.enable = false;
  local.hardware-clock.enable = true;

  networking = {
    networkmanager = {
      enable = true;
      plugins = with pkgs; [
        networkmanager-openvpn
      ];
    };
    hostName = "${host}";
    timeServers = options.networking.timeServers.default ++ [ "pool.ntp.org" ];
  };
  services.automatic-timezoned.enable = true;

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  services = {
    xserver = {
      enable = false;
      videoDrivers = [ "amdgpu" ]; # Cruciaal voor herkenning
      xkb = {
        layout = "${keyboardLayout}";
        variant = "intl";
      };
    };

    tumbler.enable = true;

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    udev.enable = true;
    envfs.enable = true;
    dbus.enable = true;

    fstrim = {
      enable = true;
      interval = "weekly";
    };

    libinput.enable = true;
    rpcbind.enable = true;
    nfs.server.enable = true;
    openssh.enable = true;
    flatpak.enable = true;
    blueman.enable = true;

    hardware.openrgb.enable = true;
    hardware.openrgb.motherboard = "amd";

    fwupd.enable = true;
    upower.enable = true;

    printing = {
      enable = true;
      drivers = [ pkgs.hplipWithPlugin ];
    };

    syncthing = {
      enable = false;
      user = "${username}";
      dataDir = "/home/${username}";
      configDir = "/home/${username}/.config/syncthing";
    };
  };

  systemd.services.flatpak-repo = {
    path = [ pkgs.flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    '';
  };

  zramSwap = {
    enable = true;
    priority = 100;
    memoryPercent = 30;
    swapDevices = 1;
    algorithm = "zstd";
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "schedutil";
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings.General.Experimental = true;
    };
  };

  services.pulseaudio.enable = false;

  security = {
    rtkit.enable = true;
    polkit.enable = true;
    polkit.extraConfig = ''
       polkit.addRule(function(action, subject) {
         if (
           subject.isInGroup("users")
             && (
               action.id == "org.freedesktop.login1.rebuild" ||
               action.id == "org.freedesktop.login1.reboot" ||
               action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
               action.id == "org.freedesktop.login1.power-off" ||
               action.id == "org.freedesktop.login1.power-off-multiple-sessions"
             )
           )
         {
           return polkit.Result.YES;
         }
      })
    '';
    pam.services.swaylock.text = "auth include login";
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
      substituters = [
        "https://cache.nixos.org/"
        "https://hyprland.cachix.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  #virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  virtualisation.podman = {
    enable = true;
    dockerCompat = false;
    defaultNetwork.settings.dns_enabled = true;
  };

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      rocmPackages.clr.icd
      rocmPackages.clr
      rocmPackages.rocminfo
      libvdpau-va-gl
      vulkan-tools
      vulkan-loader
    ];
  };

  console.keyMap = "us";

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    VKD3D_FEATURE_LEVEL = "12_0";
    RADV_PERFTEST = "rt";
  };

  system.stateVersion = "26.05";

  xdg.portal.enable = true;

  # Browser teruggezet naar Librewolf
  xdg.mime.defaultApplications = {
    "text/html" = "librewolf.desktop";
    "x-scheme-handler/http" = "librewolf.desktop";
    "x-scheme-handler/https" = "librewolf.desktop";
    "x-scheme-handler/about" = "librewolf.desktop";
    "x-scheme-handler/unknown" = "librewolf.desktop";
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -l";
      v = "nvim";
      upd = "nh os switch";
      upd-full = "nh os switch --update";
      gc = "sudo nix-collect-garbage -d && nix-store --optimize";
      conf = "nvim ~/NixOS-Hyprland/hosts/DeusExMachina/config.nix";
      ap = "nvim ~/NixOS-Hyprland/hosts/DeusExMachina/packages-fonts.nix";
      dcup = "docker compose up -d";
      dcd = "docker compose down";
      dcdd = "docker compose down -v";
    };
    interactiveShellInit = ''
      export FLAKE="/home/brik/NixOS-Hyprland"
      export PATH=$PATH:/home/brik/scripts
      fastfetch
        # De alias die qadd omzet in een inline Zsh-script
        alias qadd='noglob zsh -c "
            curl -s -c /tmp/qcookies.txt -X POST -d \"username=DeusExMachina&password=BrikDeBaksteen\" http://localhost:8080/api/v2/auth/login > /dev/null;
            curl -i -b /tmp/qcookies.txt -X POST -d \"urls=\$1\" http://localhost:8080/api/v2/torrents/add
        " --'
    '';
    ohMyZsh = {
      enable = true;
      theme = "agnoster";
      plugins = [ "git" "sudo" "docker" "gh" "z" "docker-compose" "github" ];
    };
  };

  virtualisation.virtualbox.host = {
    enable = true;
    enableExtensionPack = true; # USB 2/3, RDP, PXE — vereist voor vagrant vbox plugin
    enableHardening = false;
    addNetworkInterface = true; # maakt vboxnet0 aan voor host-only networking
  };

  virtualisation.docker = {
    enable = true;
    rootless.enable = true;
  };

  users.users.brik.extraGroups = [ "libvirtd" "networkmanager" "wheel" "vboxusers" "docker" ];

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    nspr
    nss
    atk
    at-spi2-atk
    cups
    libdrm
    libglvnd
    mesa
    pango
    cairo
    libX11
    libXcomposite
    libXdamage
    libXext
    libXfixes
    libXrandr
    libxcb
    libxkbcommon
    expat
    systemd
    xorg.libXxf86vm
    xorg.libX11
    xorg.libXext

    # Nodig voor je videokaart en geluid
    libGL
    libpulseaudio

    # Nodig voor Java & andere bibliotheken
    stdenv.cc.cc.lib
    xorg.libXcursor
    xorg.libXrandr

    libXxf86vm
    libXcursor
    libXi
    libXrandr
    libXinerama
  ];

  programs.gamescope.enable = true;

  documentation = {
    enable = true;
    doc.enable = false;
    dev.enable = false;
    man.enable = false;
    nixos.enable = false;
  };

  # Fix voor RPCS3 memory limits
  security.pam.loginLimits = [
    { domain = "*"; type = "soft"; item = "memlock"; value = "unlimited"; }
    { domain = "*"; type = "hard"; item = "memlock"; value = "unlimited"; }
  ];

  hardware.enableAllFirmware = true;

  programs.java.enable = true;
  environment.systemPackages = with pkgs; [
    zulu8 # Of openjdk8
    vagrant # VirtualBox provider
    (glances.overrideAttrs (old: { doCheck = false; }))
  ];
  programs.gamemode.enable = true;

  services.ollama = {
   enable = true;
   package = pkgs.ollama-rocm;
   rocmOverrideGfx = "11.0.0"; # Cruciaal voor de 9070 XT
   };

  #systemd.services.ollama.after = [ "display-manager.service" ];
  nixpkgs.overlays = [
    (final: prev: {
      # Slaat de falende synchronisatie-test van OpenLDAP over (nodig voor Lutris/Bottles)
      openldap = prev.openldap.overrideAttrs (oldAttrs: {
        doCheck = false;
      });


      # Fix voor de Wireshark hash mismatch (als je versie 4.6.5 wilt blijven gebruiken)
      wireshark-qt = prev.wireshark-qt.overrideAttrs (oldAttrs: {
        src = prev.fetchurl {
          url = "https://2.na.dl.wireshark.org/src/all-versions/wireshark-4.6.5.tar.xz";
          hash = "sha256-Zvrwxjp4LK2J3QnxmPxKKrU01YHQvPyp54UWzeGNCjA="; # De 'got' hash uit je error
        };
      });
    })
  ];
  environment.etc."force-rebuild".text = "DeusExMachina-Herstel-1";

  services.qbittorrent = {
    enable = true;
    openFirewall = true;
    serverConfig = {
      Preferences = {
        "WebUI\\Username" = "DeusExMachina";
        "WebUI\\AuthSubnetWhitelist" = "127.0.0.1/32";
        "WebUI\\LocalHostAuth" = false; # Dit zet de beveiliging voor localhost uit
        "Downloads\\SavePath" = "/mnt/sda1/torrents";
      };
    };
  };
  services.avahi = {
    enable = true;
    nssmdns4 = true;
  };
}



