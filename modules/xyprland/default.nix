{ config, lib, inputs, ... }:
with lib;
let
  cfg = config.programs.xyprland;
  helpers = import ./helpers.nix;
  customTypes = import ./custom_types.nix lib;
in {
  imports = with inputs; [ hyprland.homeManagerModules.default ];

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

    options = let
      mkNullOption = (option:
        mkOption option // {
          type = with types; nullOr (option.type);
          default = null;
        });
    in {
      general = {
        border_size = mkNullOption { type = types.ints.unsigned; };
        no_border_on_floating = mkNullOption { type = types.bool; };
        gaps_in = mkNullOption { type = types.ints.unsigned; };
        gaps_out = mkNullOption { type = types.ints.unsigned; };
        cursor_inactive_timeout = mkNullOption { type = types.ints.unsigned; };
        layout =
          mkNullOption { type = with types; enum [ "dwindle" "master" ]; };
        no_cursor_wraps = mkNullOption { type = types.bool; };
        no_focus_fallback = mkNullOption { type = types.bool; };
        apply_sens_to_raw = mkNullOption { type = types.bool; };
        resize_on_border = mkNullOption { type = types.bool; };
        extend_border_grab_area = mkNullOption { type = types.ints.unsigned; };
        hover_icon_on_border = mkNullOption { type = types.bool; };
        allow_tearing = mkNullOption { type = types.bool; };
        "col.inactive_border" = mkNullOption { type = types.str; };
        "col.active_border" = mkNullOption { type = types.str; };
        "col.no_group_border " = mkNullOption { type = types.str; };
        "col.no_group_border_active" = mkNullOption { type = types.str; };
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
        description = "Lines to add before module configuration.";
        default = "";
      };
      post = mkOption {
        type = types.lines;
        description = "Lines to add after module configuration.";
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
      xwayland.enable = cfg.xwayland.enable;
      extraConfig = with helpers; ''
        ${cfg.extraConfig.pre}

        ${writeOpts.general cfg.options.general}
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
