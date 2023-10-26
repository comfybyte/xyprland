hyprland:
{ config, lib, pkgs, ... }:
let
  inherit (lib) types;
  cfg = config.programs.xyprland;
  helpers = import ./helpers.nix;
  customTypes = import ./custom_types.nix lib;
in {
  imports = [ hyprland.homeManagerModules.default ./submodules/options.nix ];

  options.programs.xyprland = {
    enable = lib.mkEnableOption "Whether to enable this module.";

    hyprland = lib.mkOption {
      type = types.anything;
      description =
        ''
        Configuration to be passed down to `wayland.windowManager.hyprland`.
        Overwrites Xyprland's configuration.
        See <https://nix-community.github.io/home-manager/options.html#opt-wayland.windowManager.hyprland.enable>.
        '';
      example = lib.literalExpression ''
        {
          enableNvidiaPatches = true;
        }
      '';
      default = { };
    };

    mod = {
      key = lib.mkOption {
        type = types.str;
        description =
          "Which key to use as mod. Referenced with $mod by default.";
        example = "ALT";
        default = "SUPER";
      };

      name = lib.mkOption {
        type = types.str;
        description = "A name for the mod variable.";
        example = "modKey";
        default = "mod";
      };
    };

    monitors = lib.mkOption {
      type = with types; listOf (listOf str);
      description = "A list of monitor configurations as lists.";
      example = lib.literalExpression ''
        [ [ "DP-1" "1920x1080@60" "0x0" "1" ] ]
      '';
      default = [ ];
    };

    env = lib.mkOption {
      type = with types; attrsOf str;
      description = "A set of environment variables to add.";
      example = lib.literalExpression ''
        {
          QT_QPA_PLATFORM = "wayland";
          XDG_CURRENT_DESKTOP = "Hyprland";
        };
      '';
      default = [ ];
    };

    binds = lib.mkOption {
      type = types.listOf customTypes.bind;
      description = "A list of keybinds.";
      default = [ ];
    };

    submaps = lib.mkOption {
      type = with types;
        either (listOf customTypes.submap) (attrsOf (listOf customTypes.bind));
      description = ''
        Submaps to add as either a set with each value being a list of binds, or a list of custom submodules.
      '';
      default = { };
    };

    windowRules = lib.mkOption {
      type = types.listOf customTypes.windowRule;
      description = "A list of window rules.";
      default = [ ];
    };

    defaultWorkspaces = lib.mkOption {
      type = with types;
        attrsOf (listOf (either str customTypes.defaultWorkspace));
      description =
        "A set of workspace names mapped to a list of windows that should be moved to them.";
      default = { };
    };

    onceStart = lib.mkOption {
      type = with types; listOf str;
      description = "A list of commands to execute on startup, once.";
      default = [ ];
    };

    extraConfig = {
      pre = lib.mkOption {
        type = types.lines;
        description = "Lines to prepend to configuration file.";
        default = "";
      };
      post = lib.mkOption {
        type = types.lines;
        description = "Lines to postpend to configuration file.";
        default = "";
      };
    };

    waybar = lib.mkOption {
      type = types.anything;
      description = "Waybar options.";
      default = {};
    };
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      package = hyprland.packages."${pkgs.system}".hyprland;

      extraConfig = with helpers; ''
        ${cfg.extraConfig.pre}

        ${writeOptions cfg.options}
        ${"$" + cfg.mod.name} = ${cfg.mod.key}
        ${writeMonitors cfg.monitors}
        ${writeOnceStart cfg.onceStart}

        ${writeSubmaps cfg.submaps}
        ${writeBinds cfg.binds}

        ${writeVars cfg.env}

        ${writeWindowRules cfg.windowRules}
        ${writeDefaultWorkspaces cfg.defaultWorkspaces}

        ${cfg.extraConfig.post}
      '';
    } // cfg.hyprland;

    programs.waybar = cfg.waybar;
  };
}
