{
  description = "Configure Hyprland with Nix.";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
  };
  outputs = { ... }: {
    homeManagerModules.xyprland = import ./modules/xyprland;
  };
}
