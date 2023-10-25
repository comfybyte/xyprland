{ config, lib, pkgs, ... }:
hyprland:
with lib;
let
  cfg = config.programs.xyprland;
  helpers = import ./helpers.nix;
  customTypes = import ./custom_types.nix lib;
in {
  imports = [ hyprland.homeManagerModules.default ./submodules/options.nix ];

  options.programs.xyprland = {
    enable = mkEnableOption "Whether to enable this module.";

    xwayland.enable = mkEnableOption "Whether to enable XWayland.";

    mod = {
      key = mkOption {
        type = types.str;
        description =
          "Which key to use as mod. Referenced with $mod by default.";
        example = "ALT";
        default = "SUPER";
      };

      name = mkOption {
        type = types.str;
        description = "A name for the mod variable.";
        example = "modKey";
        default = "mod";
      };
    };

    monitors = mkOption {
      type = with types; listOf (listOf str);
      description = "A list of monitor configuration lists.";
      example = ''
        [ [ "DP-1" "1920x1080@60" "0x0" "1" ] ]
      '';
      default = [ ];
    };

    env = mkOption {
      type = with types; attrsOf str;
      description = "A set of environment variables to add.";
      example = ''
        {
          QT_QPA_PLATFORM = "wayland";
          XDG_CURRENT_DESKTOP = "Hyprland";
        };
      '';
      default = [ ];
    };

    binds = mkOption {
      type = types.listOf customTypes.bind;
      description = "A list of keybinds.";
      default = [ ];
    };

    submaps = mkOption {
      type = with types;
        either (listOf customTypes.submap) (attrsOf customTypes.bind);
      description = ''
        Submaps to add as either a set with each value being a list of binds, or a list of custom submodules.
      '';
      default = { };
    };

    windowRules = mkOption {
      type = types.listOf customTypes.windowRule;
      description = "A list of window rules.";
      default = [ ];
    };

    defaultWorkspaces = mkOption {
      type = with types;
        attrsOf (listOf (either str customTypes.defaultWorkspace));
      description =
        "A set of workspace names mapped to a list of windows that should be moved to them.";
      default = { };
    };

    onceStart = mkOption {
      type = with types; listOf str;
      description = "A list of commands to execute on startup, once.";
      default = [ ];
    };

    extraConfig = {
      pre = mkOption {
        type = types.lines;
        description = "Lines to prepend to configuration file.";
        default = "";
      };
      post = mkOption {
        type = types.lines;
        description = "Lines to postpend to configuration file.";
        default = "";
      };
    };

    waybar = {
      enable = mkEnableOption "Enable Waybar.";
      style = mkOption {
        type = types.lines;
        description = "CSS styling.";
        default = "";
      };
      settings = mkOption {
        type = with types; attrsOf anything;
        default = { };
      };
    };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages."${pkgs.system}".hyprland;
      xwayland.enable = cfg.xwayland.enable;

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
    };

    programs.waybar = cfg.waybar;
  };
}
