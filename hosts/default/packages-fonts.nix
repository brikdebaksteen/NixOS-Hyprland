# 💫 https://github.com/JaKooLit 💫 #
# Packages for this host only
{pkgs, ...}: let
  python-packages = pkgs.python3.withPackages (
    ps:
      with ps; [
        requests
        pyquery # needed for hyprland-dots Weather script
      ]
  );
in {
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages =
    (with pkgs; [
      # System Packages
	fastfetch
	librewolf
	obsidian
	lobster
	ani-cli
	lazygit
    ])
    ++ [
      python-packages
    ];

  programs = {
    steam = {
      enable = false;
      gamescopeSession.enable = false;
      remotePlay.openFirewall = false;
      dedicatedServer.openFirewall = false;
    };
  };
}
