# 💫 https://github.com/JaKooLit 💫 #
# Packages for this host only
{ pkgs, ... }:
let
  python-packages = pkgs.python3.withPackages (
    ps:
      with ps; [
        requests
        pyquery # needed for hyprland-dots Weather script
        jupyter
        ipykernel
        pandas
        numpy
        matplotlib
      ]
  );
in
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages =
    (with pkgs; [
      # --- Web Browsers & Internet ---
      firefox
      librewolf
      vesktop # Custom Discord client
      (prismlauncher.override {
        jdks = [ jdk8 jdk17 jdk21 ];
      })
      # --- Development & Programming ---
      docker
      gh # GitHub CLI
      jetbrains.idea
      jetbrains.webstorm
      jq # Command-line JSON processor
      lazygit
      nodejs
      python312
      python312Packages.pip
      python312Packages.virtualenv
      temurin-bin-17 # Java 17
      temurin-bin-21 # Java 21
      temurin-bin-8 # Java 8
      vscode
      swww

      # --- Gaming, Wine & Proton ---
      bottles # Wine prefix manager
      corectrl # Systeemprofielen/overclocking (GPU/CPU)
      heroic # Epic/GOG/Amazon games launcher
      lutris
      mangohud # Gaming overlay (FPS, temps)
      prismlauncher # Minecraft launcher
      protonup-qt # Proton/Wine-GE installer
      wineWow64Packages.stable
      winetricks
      piper
      steam-run
      libXxf86vm
      vulkan-tools
      vulkan-loader
      # --- Emulators (Stand-alone) ---
      dolphin-emu # GameCube / Wii
      pcsx2 # PS2
      ppsspp # PSP
      rpcs3 # PS3
      ryubing # <--- De vervanger voor Ryujinx (Switch)
      shadps4 # PS4

      # --- Media & Entertainment ---
      ani-cli # Anime CLI
      ffmpeg
      imagemagick
      mpv # Media player
      spotify
      yt-dlp # Video/Audio downloader

      # --- Productivity & Office ---
      obsidian
      zathura # Minimalistische PDF reader

      # --- System Tools & Desktop Utilities ---
      fastfetch # Systeeminformatie
      fzf # Command-line fuzzy finder
      glfw
      gvfs # Virtual filesystem (voor trash, mounts, etc)
      kanshi # Display auto-configuratie (Wayland)
      nwg-look # GTK theme instellingen voor wlroots/Wayland
      pavucontrol # Audio/PulseAudio volume beheer
      timeshift # Systeem back-ups
      tmux # Terminal multiplexer
      tree # Mappenstructuur visualisatie
      wget
      solaar
      baobab

      # --- Archiving & Compression ---
      p7zip
      unrar
      unzip
      zip

      # --- Networking, Security & AI ---
      aircrack-ng # Netwerk security tool
      ollama # Lokale LLM (AI) runner
      rclone # Cloud storage sync tool
      tcpdump # Netwerkverkeer analyzer
      #wireshark # Grafische netwerk analyzer
      xmrig # CPU/GPU miner
    ])
    ++ [
      python-packages
    ]
    ++ [
      # --- RetroArch met geïntegreerde cores ---
      (pkgs.retroarch.withCores (cores: with cores; [
        mgba # Gameboy Advance
        snes9x # SNES
        beetle-psx-hw # PS1
        mupen64plus # N64
        nestopia # NES
        genesis-plus-gx # Sega Genesis / Mega Drive
      ]))
    ]; # <--- Zorg dat deze puntkomma de lijst afsluit!   

  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };
  };

  # Verwijder de losse .enable regel die erboven staat!

  services.gvfs = {
    enable = true;
    package = pkgs.gvfs;
  };

  services.ratbagd.enable = true;
  hardware.logitech.wireless.enable = true;
  hardware.logitech.wireless.enableGraphical = true; # Optioneel voor Solaar

  fonts.packages = with pkgs; [
    dejavu_fonts
    freefont_ttf
    liberation_ttf
    corefonts
  ];
}
