{ pkgs
, lib
, config
, ...
}: {
  # Install themes/cursors that we reference
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    papirus-icon-theme
    bibata-cursors
    adwaita-qt
  ];

  # Environment variables as a fallback for apps not honoring gsettings
  environment.variables = {
    GTK2_RC_FILES = "${pkgs.gnome-themes-extra}/share/themes/Adwaita-dark/gtk-2.0/gtkrc";
    QT_QPA_PLATFORMTHEME = "gtk3";
  };

  # Cursor defaults for XDG/Wayland sessions
  environment.sessionVariables = {
    XCURSOR_THEME = "Bibata-Modern-Classic";
    XCURSOR_SIZE = "24";
  };

  # Set system dconf defaults so new users prefer dark by default.
  # Users can still override per-user via gsettings.
  programs.dconf.profiles.user.databases = [{
    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = lib.gvariant.mkString "prefer-dark";
        gtk-theme = lib.gvariant.mkString "adw-gtk3-dark";
      };
    };
  }];

  # Rebuild the dconf database at activation to apply system defaults
  system.activationScripts.dconfUpdate = {
    deps = [ "etc" ];
    text = ''
      if [ -x ${pkgs.dconf}/bin/dconf ]; then
        if [ -d /etc/dconf/db ]; then
          ${pkgs.dconf}/bin/dconf update || true
        fi
      fi
    '';
  };
}
