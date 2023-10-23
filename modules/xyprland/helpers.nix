rec {
  mapToLines =
    (items: map: builtins.concatStringsSep "\n" (builtins.map map items));

  isSetEmpty = set: builtins.length (builtins.attrNames set) == 0;

  isSetNull = set:
    builtins.all (value: value == null) (builtins.attrValues set);

  isNullSet = set: isSetEmpty set || isSetNull set;

  toHyprlandObj = (set:
    let
      lines = builtins.filter (line: line != null) (builtins.attrValues
        (builtins.mapAttrs (name: value:
          let
            isSet = builtins.isAttrs value;
            content = if isSet then
              (if isNullSet value then null else (toHyprlandObj value))
            else
              (if value == null then null else value);
          in (if content == null then
            null
          else
            "${name}${if isSet then " " else " = "}${
              builtins.toString content
            }")) set));
    in ''
      {
        ${builtins.concatStringsSep "\n  " lines}
      }
    '');

  writeMonitors = (monitors:
    mapToLines monitors (monitor:
      with monitor;
      "monitor = ${name},${resolution},${position},${scale}"));

  writeVars =
    (env: mapToLines env (var: "env = ${with var; name + delimiter + value}"));

  writeBinds = (binds:
    mapToLines binds (bind:
      let flags = (if bind.flags == null then "" else bind.flags);
      in "bind${flags} = ${bind.text}"));

  writeWindowRules = (rules:
    mapToLines rules (rule: "windowrule = ${rule.rule},${rule.window}"));

  writeDefaultWorkspaces = (defaultWorkspaces:
    builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs
      (workspace: windows:
        mapToLines windows (window:
          let
            isSet = builtins.isAttrs window;
            silent = if isSet && window.silent then " silent" else "";
          in "windowrule = workspace ${workspace}${silent}, ${
            if isSet then window.text else window
          }")) defaultWorkspaces)));

  writeOnceStart = (commands:
    "exec-once = "
    + (builtins.concatStringsSep ("\n" + "exec-once = ") commands));

  writeSubmaps = (submaps:
    builtins.concatStringsSep "\n\n" (builtins.attrValues (builtins.mapAttrs
      (submap: binds: ''
        submap = ${submap}
        ${writeBinds binds}
        bind = , escape, submap, reset
      '') submaps)) + "\n" + "submap = reset");

  writeOpts = {
    general = general: ''
      general ${toHyprlandObj general}
    '';
  };
}
