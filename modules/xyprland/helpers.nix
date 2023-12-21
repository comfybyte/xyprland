rec {
  toLines = strList: builtins.concatStringsSep "\n" strList;

  mapToLines = items: map: toLines (filterNull (builtins.map map items));

  # There are no items.
  isEmptySet = s: builtins.length (builtins.attrNames s) == 0;

  # All items are null.
  isNullSet = s: builtins.all (i: i == null) (builtins.attrValues s);

  # All items are null or empty.
  isBlankSet = s:
    builtins.all (i: builtins.isAttrs i && (isEmptySet i || isNullSet i))
    (builtins.attrValues s);

  isDeadSet = s: isEmptySet s || isNullSet s || isBlankSet s;

  filterNull = list: builtins.filter (i: i != null) list;

  parseBool = a: if a == true then 1 else 0;

  toHyprlandObj = set:
    let
      parseSpecial = a: if builtins.isBool a then (parseBool a) else a;
      lines = filterNull (builtins.attrValues (builtins.mapAttrs (name: value:
        let
          isSet = builtins.isAttrs value;
          content = if isSet then
            (if isDeadSet value then null else (toHyprlandObj value))
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
    mapToLines monitors (monitor: "monitor = ${monitor}");

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

  writeWindowRules = rules: v:
    toLines (builtins.attrValues (builtins.mapAttrs (rule: windows:
      mapToLines windows (window:
        "windowrule${if v == "v1" then "" else "v2"} = ${rule}, ${window}"))
      rules));

  writeDefaultWorkspaces = defaultWorkspaces:
    builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs
      (workspace: windows:
        mapToLines windows (window:
          let
            isSet = builtins.isAttrs window;
            silent = if isSet && window.silent then " silent" else "";
            text = if isSet then window.text else window;
          in "windowrulev2 = workspace ${workspace}${silent}, ${text}"))
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

  writeGlobals = globals:
    toLines (builtins.attrValues
      (builtins.mapAttrs (name: value: "${"$" + name} = ${value}") globals));

  writeAnimations = animations:
    mapToLines animations (animation: "animation = ${animation}");

  writeCurves = curves: mapToLines curves (curve: "bezier = ${curve}");

  writeOptions = options:
    toLines (filterNull (builtins.attrValues (builtins.mapAttrs (name: value:
      if isNullSet value then
        null
      else ''
        ${name} ${toHyprlandObj value}
      '') options)));
}
