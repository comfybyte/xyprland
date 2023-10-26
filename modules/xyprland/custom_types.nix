lib:
let inherit (lib) types;
in rec {
  bind = types.submodule {
    options = {
      enable = lib.mkEnableOption "Whether to enable this keybind." // {
        default = true;
      };
      flags = lib.mkOption {
        type = with types; nullOr str;
        description =
          "A string of bind flags to add (<https://wiki.hyprland.org/Configuring/Binds/#bind-flags>).";
        example = "le";
        default = "";
      };
      text = lib.mkOption {
        type = types.str;
        description = "This bind's contents.";
        example = "SUPER, Q, killactive, ";
      };
    };
  };

  submap = types.submodule {
    options = {
      enable = lib.mkEnableOption "Whether to enable this submap." // {
        default = true;
      };
      name = lib.mkOption {
        type = types.str;
        description = "This submap's name.";
        example = "resize";
      };
      binds = lib.mkOption {
        type = types.listOf bind;
        description = "A list of binds to enable while inside this submap.";
        default = [ ];
      };
      exit = lib.mkOption {
        type = bind;
        description = "A bind to exit this submap. Defaults to Escape.";
        default = { text = ", escape, submap, reset"; };
      };
    };
  };

  windowRule = types.submodule {
    options = {
      enable = lib.mkEnableOption "Whether to enable this window rule." // {
        default = true;
      };
      rule = lib.mkOption { type = types.str; };
      window = lib.mkOption { type = types.str; };
    };
  };

  defaultWorkspace = types.submodule {
    options = {
      text = lib.mkOption { type = types.str; };
      silent = lib.mkEnableOption "Whether to not switch to it when opened.";
    };
  };
}
