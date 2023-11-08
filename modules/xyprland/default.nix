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
      description = ''
        Alias for `wayland.windowManager.hyprland`.
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

    enablePortal = lib.mkEnableOption "Whether to enable `xdg-desktop-portal-hyprland`.";

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
      example = lib.literalExpression ''
      {
        resize = [
          # Binds go here...
        ];
      }
      '';
      default = { };
    };

    windowRules = lib.mkOption {
      type = with types; attrsOf (listOf str);
      description = "A set of window rules mapped to lists of windows.";
      example = lib.literalExpression ''
      {
        opaque = [ "title:^alacritty$" ];
      }
      '';
      default = { };
    };

    windowRulesV2 = lib.mkOption {
      type = with types; attrsOf (listOf str);
      description = "Same as windowRules but for v2 rules (can match many windows).";
      example = lib.literalExpression ''
      {
        opaque = [ "title:^alacritty$, title:^kitty$" ];
      }
      '';
      default = { };
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

    globals = lib.mkOption {
      type = with types; attrsOf str;
      description = "A set of variables that may be used in other options.";
      example = lib.literalExpression ''
        {
          black = "rgb(000000)";
        }
      '';
      default = { };
    };

    animation = {
      enable = lib.mkEnableOption "Enable animations.";
      animations = lib.mkOption {
        type = with types; listOf str;
        description = "A list of animations.";
        example = lib.literalExpression ''
          [
            "workspaces, 1, 8, default"
          ]
        '';
        default = [ ];
      };
      beziers = lib.mkOption {
        type = with types; listOf str;
        description = "A list of bezier curves.";
        example = lib.literalExpression ''
          [
            "overshot, 0.05, 0.9, 0.1, 1.1"
          ]
        '';
        default = [ ];
      };
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
  };

  config = lib.mkIf cfg.enable {
    xdg.portal.extraPortals = lib.mkIf cfg.enablePortal [ pkgs.xdg-desktop-portal-hyprland ];

    wayland.windowManager.hyprland = {
      enable = true;
      package = hyprland.packages."${pkgs.system}".hyprland;

      extraConfig = with helpers; ''
        ${cfg.extraConfig.pre}

        ${writeOptions cfg.options}
        ${writeGlobals cfg.globals}
        ${"$" + cfg.mod.name} = ${cfg.mod.key}
        ${writeMonitors cfg.monitors}
        ${writeOnceStart cfg.onceStart}
        ${writeSubmaps cfg.submaps}
        ${writeBinds cfg.binds}

        animations {
          enabled = ${toString (parseBool cfg.animation.enable)}
          ${writeCurves cfg.animation.beziers}
          ${writeAnimations cfg.animation.animations}
        }

        ${writeVars cfg.env}

        ${writeWindowRules cfg.windowRules "v1"}
        ${writeWindowRules cfg.windowRulesV2 "v2"}
        ${writeDefaultWorkspaces cfg.defaultWorkspaces}

        ${cfg.extraConfig.post}
      '';
    } // cfg.hyprland;
  };
}
