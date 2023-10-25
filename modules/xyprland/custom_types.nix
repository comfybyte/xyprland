lib:
with lib; rec {
  bind = types.submodule {
    options = {
      enable = mkEnableOption "Whether to enable this keybind." // {
        default = true;
      };
      flags = mkOption {
        type = with types; nullOr str;
        description =
          "A string of bind flags to add (<https://wiki.hyprland.org/Configuring/Binds/#bind-flags>).";
        example = "le";
        default = "";
      };
      text = mkOption {
        type = types.str;
        description = "This bind's contents.";
        example = "SUPER, Q, killactive, ";
      };
    };
  };

  submap = types.submodule {
    options = {
      enable = mkEnableOption "Whether to enable this submap." // {
        default = true;
      };
      binds = mkOption {
        type = types.listOf bind;
        description = "A list of binds to enable while inside this submap.";
        default = [ ];
      };
      exit = mkOption {
        type = bind;
        description = "A bind to exit this submap. Defaults to Escape.";
        default = { text = ", escape, submap, reset"; };
      };
    };
  };

  windowRule = types.submodule {
    options = {
      enable = mkEnableOption "Whether to enable this window rule." // {
        default = true;
      };
      rule = mkOption { type = types.str; };
      window = mkOption { type = types.str; };
    };
  };

  defaultWorkspace = types.submodule {
    options = {
      text = mkOption { type = types.str; };
      silent = mkEnableOption "Whether to not switch to it when opened.";
    };
  };
}
