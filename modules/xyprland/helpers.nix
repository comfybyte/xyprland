rec {
  toLines = strList: builtins.concatStringsSep "\n" strList;

  mapToLines = items: map: toLines (filterNull (builtins.map map items));

  isSetEmpty = set: builtins.length (builtins.attrNames set) == 0;

  isSetNull = set:
    builtins.all (value: value == null) (builtins.attrValues set);

  isNullSet = set: isSetEmpty set || isSetNull set;

  filterNull = list: builtins.filter (i: i != null) list;

  toHyprlandObj = set:
    let
      parseBool = a: if a == true then 1 else 0;
      parseSpecial = a: if builtins.isBool a then (parseBool a) else a;
      lines = filterNull (builtins.attrValues (builtins.mapAttrs (name: value:
        let
          isSet = builtins.isAttrs value;
          content = if isSet then
            (if isNullSet value then null else (toHyprlandObj value))
          else
            parseSpecial value;
        in (if content == null then
          null
        else
          "${name}${if isSet then " " else " = "}${builtins.toString content}"))
        set));
    in ''
      {
        ${builtins.concatStringsSep "\n  " lines}
      }
    '';

  writeMonitors = monitors:
    mapToLines monitors
    (monitor: "monitor = " + (builtins.concatStringsSep ", " monitor));

  writeVars = env:
    toLines (builtins.attrValues
      (builtins.mapAttrs (name: value: "env = ${name},${value}") env));

  writeBinds = binds:
    mapToLines binds (bind:
      if bind.enable then
        let flags = (if bind.flags == null then "" else bind.flags);
        in "bind${flags} = ${bind.text}"
      else
        null);

  writeWindowRules = rules:
    mapToLines rules (rule:
      if rule.enable then
        "windowrule = ${rule.rule}, ${rule.window}"
      else
        null);

  writeDefaultWorkspaces = defaultWorkspaces:
    builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs
      (workspace: windows:
        mapToLines windows (window:
          let
            isSet = builtins.isAttrs window;
            silent = if isSet && window.silent then " silent" else "";
            text = if isSet then window.text else window;
          in "windowrule = workspace ${workspace}${silent}, ${text}"))
      defaultWorkspaces));

  writeOnceStart = commands:
    "exec-once = "
    + (builtins.concatStringsSep ("\n" + "exec-once = ") commands);

  writeSubmaps = submaps:
    (builtins.concatStringsSep "\n\n" (filterNull
      (if builtins.isAttrs submaps then
        builtins.attrValues (builtins.mapAttrs (submap: binds: ''
          submap = ${submap}
          ${writeBinds binds}
          bind = , escape, submap, reset
        '') submaps)
      else
        builtins.map (submap:
          if submap.enable then
            with submap;
            ''
              submap = ${name}
              ${writeBinds binds}
            '' + (if exit && exit.enable then
              "bind${exit.flags} = ${exit.text}"
            else
              "bind = , escape, submap, reset")
          else
            null) submaps)) + "\n" + "submap = reset");

  writeOptions = options:
    builtins.concatStringsSep "\n" (filterNull (builtins.attrValues
      (builtins.mapAttrs (name: value:
        if isNullSet value then
          null
        else ''
          ${name} ${toHyprlandObj value}
        '') options)));
}
