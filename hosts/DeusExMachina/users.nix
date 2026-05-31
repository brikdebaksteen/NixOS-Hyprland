# 💫 https://github.com/JaKooLit 💫 #
# Users - NOTE: Packages defined on this will be on current user only
{
  pkgs,
  username,
  ...
}: let
  inherit (import ./variables.nix) gitUsername;
in {
  users = {
    mutableUsers = true;
    users."${username}" = {
      homeMode = "755";
      isNormalUser = true;
      description = "${gitUsername}";
      extraGroups = [
        "networkmanager"
        "wheel"
        "libvirtd"
        "scanner"
        "lp"
        "video"
        "input"
        "audio"
        "vboxusers"
      ];

      # define user packages here
      packages = with pkgs; [
      ];
    };

    defaultUserShell = pkgs.zsh;
  };

  environment.shells = with pkgs; [zsh];
  environment.systemPackages = with pkgs; [lsd fzf git];
  programs = {
    zsh = {
      ohMyZsh = {
        enable = true;
        theme = "agnoster";
        plugins = ["git"];
      };
      # Enable zsh plugins via NixOS module options
      autosuggestions.enable = true;
      syntaxHighlighting.enable = true;
    };
  };
  environment.shellAliases = {
  gap = "git -C ~/NixOS-Hyprland add .";
  update-pc = "git -C ~/NixOS-Hyprland add . && sudo nixos-rebuild switch --flake ~/NixOS-Hyprland#DeusExMachina && nix flake update ~/NixOS-Hyprland";
};
}
