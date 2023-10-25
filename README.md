# Xyprland
A [Home Manager](https://github.com/nix-community/home-manager) module for 
configuring [Hyprland](https://github.com/hyprwm/Hyprland) using Nix expressions, 
inspired by [Nixvim](https://github.com/nix-community/nixvim).

Spawned from my need to organise my configs ~~less badly~~ more decently and since I couldn't find anything
similar (for some reason, weirdly enough). Very much a work-in-progress but usable.

### Installation
**With [flakes](https://nixos.wiki/wiki/Flakes):**

1. Add this repository as an input:
```nix
{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
        xyprland.url = "github:comfybyte/xyprland";
        
        home-manager = {
            url = "github:nix-community/home-manager";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        # Note: Hyprland input not required, as it's already used.
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
**⚠️ There's no documentation (at least not yet), 
but the [module definition](https://github.com/comfybyte/xyprland/blob/main/modules/xyprland/default.nix)
and its [submodules](https://github.com/comfybyte/xyprland/tree/main/modules/xyprland/submodules)
should hopefully be well-commented enough for now.**

An example going over **most** options:
```nix
{
    programs.xyprland = {
        enable = true;
        xwayland.enable = true;
        mod.key = "ALT"; # Default is SUPER.
        options.general = {
            layout = "dwindle";
            gaps_in = 0;
            gaps_out = 0;
            "col.active_border" = "rgb(ffffff)";
            "col.inactive_border" = "rgb(000000)";
        };
        options.decoration = {
            rounding = 2;
            blur.enabled = true;
        };
        options.misc.force_hypr_chan = true;
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
