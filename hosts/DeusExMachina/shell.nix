{ pkgs ? import <nixpkgs> {} }:
pkgs.mkShell {
  name = "miner-env";
  buildInputs = with pkgs; [
    stdenv.cc.cc.lib
    rocmPackages.clr
    openssl
    libz
  ];
  shellHook = ''
    export LD_LIBRARY_PATH="${pkgs.stdenv.cc.cc.lib}/lib:${pkgs.rocmPackages.clr}/lib:${pkgs.libz}/lib:/run/opengl-driver/lib:$LD_LIBRARY_PATH"
    # Forceer de miner om de kaart als een generieke RDNA kaart te zien als hij gfx1201 niet herkent
    echo "SRBMiner omgeving geladen voor RX 9070"
  '';
}
