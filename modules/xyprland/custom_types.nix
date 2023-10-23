lib: with lib; {
  monitor = types.submodule {
    options = {
      enable = mkEnableOption "Enable this monitor" // { default = true; };
      name = mkOption { type = types.str; };
      resolution = mkOption { type = types.str; };
      position = mkOption { type = types.str; };
      scale = mkOption { type = types.str; };
    };
  };

  envVar = types.submodule {
    options = {
      name = mkOption { type = types.str; };
      value = mkOption { type = types.str; };
      delimiter = mkOption {
        type = types.str;
        default = "=";
      };
    };
  };

  bind = types.submodule {
    options = {
      enable = mkEnableOption "Whether to enable this keybind." // {
        default = true;
      };
      flags = mkOption {
        type = with types; nullOr str;
        description =
          "A string of bind flags to add (<https://wiki.hyprland.org/Configuring/Binds/#bind-flags>).";
        default = "";
      };
      text = mkOption {
        type = types.str;
        description = "This bind's contents.";
      };
    };
  };

  windowRule = types.submodule {
    options = {
      rule = mkOption { type = types.str; };
      window = mkOption { type = types.str; };
    };
  };

  defaultWorkspace = types.submodule {
    options = {
      text = mkOption { type = types.str; };
      silent = mkEnableOption "Whether to not switch to it when opened." // {
        default = false;
      };
    };
  };
}
