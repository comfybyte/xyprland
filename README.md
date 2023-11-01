# Xyprland
A [Home Manager](https://github.com/nix-community/home-manager) module for 
configuring [Hyprland](https://github.com/hyprwm/Hyprland) using Nix expressions, 
inspired by [Nixvim](https://github.com/nix-community/nixvim). 

⚠️ This module was made as a learning project and to fit my own needs,
so if you need something simpler or looser, I highly recommend the Home Manager options instead.

### Installation
**With [flakes](https://nixos.wiki/wiki/Flakes):**

1. Add this repository as an input:
```nix
{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };

        hyprland.url = "github:hyprwm/Hyprland";
        xyprland = {
            url = "github:comfybyte/xyprland";
            inputs.hyprland.follows = "hyprland";
        };
    };
}
```

2. The module is available as `inputs.xyprland.homeManagerModules.xyprland`:
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
**⚠️  There's no documentation (neither do I plan to write one),
but the [module definition](https://github.com/comfybyte/xyprland/blob/main/modules/xyprland/default.nix)
and its [submodules](https://github.com/comfybyte/xyprland/tree/main/modules/xyprland/submodules)
should be well-commented enough if you wanna use it.**

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
            # Options are type-checked. (i.e. typos or wrong types won't even build)
            # For unchecked options, use `wayland.windowManager.hyprland`.
            general = {
                layout = "dwindle";
                gaps_in = 0;
                gaps_out = 0;
                "col.active_border" = "rgb(ffffff)";
                "col.inactive_border" = "rgb(000000)";
            };
            misc.force_hypr_chan = true;
        };
        monitors = [ 
            ["DP-1" "1920x1080@144" "0x0" "1" ] 
            ["DP-2" "1920x1080" "1920x0" "1"]
        ];
        env = {
            "QT_QPA_PLATFORM" = "wayland;xcb";
            "MOZ_ENABLE_WAYLAND" = "1";
        };
        binds = [
            { text = "$mod, Q, killactive, "; }
            { text = "$mod, mouse:272, movewindow"; flags = "m"; }
        ];
        animation = {
            enable = true;
            animations = [ "windows, 1, 7, default, slide" ];
            beziers = [ "overshot, 0.05, 0.9, 0.1, 1.1" ];
        };
        windowRules = {
            opaque = [ "alacritty" ];
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
You can see [my own configuration](https://github.com/comfybyte/nixcfg/tree/master/common/home-manager/xyprland)
for a practical example. 
