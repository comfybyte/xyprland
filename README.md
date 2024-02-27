## ❄️💧 xyprland
A thin configuration layer on top of the existing Home Manager options for Hyprland.
Made as a learning project and to fit my own needs.

### Installation
**With flakes:**

1. Add this repository as an input:
```nix
{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        hyprland.url = "github:hyprwm/Hyprland";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        xyprland = {
            url = "github:comfybyte/xyprland";
            inputs.hyprland.follows = "hyprland";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };
}
```

2. Import the module `inputs.xyprland.homeManagerModules.xyprland`:
```nix
# Somewhere in your Home Manager configuration.
{ inputs, ...}: {
    imports = with inputs; [
        xyprland.homeManagerModules.xyprland
        # ...
    ];
}
```

### Usage
Detailed option descriptions
can be found at [<modules/xyprland>](https://github.com/comfybyte/xyprland/blob/main/modules/xyprland/default.nix).

An example going over **most** options:
```nix
{
    programs.xyprland = {
        enable = true;
        hyprland = {
            xwayland.enable = true;
            # ...other options passed to `wayland.windowManager.hyprland`.
        };
        mod.key = "ALT"; # Default is SUPER.
        options = {
            # Can be any shape, checked after build.
            general.layout = "dwindle";
            misc.force_hypr_chan = true;
        };
        monitors = [ 
            ["DP-1, 1920x1080@144, 0x0, 1" ] 
        ];
        env = {
            QT_QPA_PLATFORM = "wayland;xcb";
            MOZ_ENABLE_WAYLAND = "1";
        };
        binds = [
            { text = "$mod, Q, killactive, "; }
            { text = "$mod, mouse:272, movewindow"; flags = "m"; }
        ];
        submaps = {
            resize = [
                # ...
            ];
        };
        animation = {
            enable = true;
            animations = [ "windows, 1, 7, default, slide" ];
            beziers = [ "overshot, 0.05, 0.9, 0.1, 1.1" ];
        };
        windowRules = { # Or windowRulesV2.
            opaque = [ "title:^alacritty$" ];
        };
        defaultWorkspaces = {
            "2" = [ "firefox" ];
            "6" = [ { text = "krita"; silent = true; } ]
        };
        onceStart = [
            "waybar"
        ];
        extraConfig.pre = import ./some_config_as_nix.nix;
        extraConfig.post = builtins.readFile ./some_config_as_plain_text;
    };
}
```
