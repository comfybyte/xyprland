{ config, lib, inputs, pkgs, ... }:
with lib;
let
  cfg = config.programs.xyprland;
  helpers = import ./helpers.nix;
  customTypes = import ./custom_types.nix lib;
in {
  imports = with inputs; [
    hyprland.homeManagerModules.default
    ./submodules/options.nix
  ];

  options.programs.xyprland = {
    enable = mkEnableOption "Whether to enable this module.";

    xwayland.enable = mkEnableOption "Whether to enable XWayland.";

    mod = {
      key = mkOption {
        type = types.str;
        description =
          "Which key to use as mod. Referenced with $mod by default.";
        default = "SUPER";
      };

      name = mkOption {
        type = types.str;
        description = "A name for the mod variable.";
        default = "mod";
      };
    };

    monitors = mkOption {
      type = types.listOf customTypes.monitor;
      description = "A list of monitor configurations.";
      default = [ ];
    };

    env = mkOption {
      type = types.listOf customTypes.envVar;
      description = "A list of environment variables.";
      default = [ ];
    };

    binds = mkOption {
      type = types.listOf customTypes.bind;
      description = "A list of keybinds.";
      default = [ ];
    };

    submaps = mkOption {
      type = with types; attrsOf (listOf customTypes.bind);
      description = ''
        A set of submap names mapped to a list of their binds.
        Automatically binds exiting to Escape.
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
