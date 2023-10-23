{ lib, ... }:
with lib; {
  options.programs.xyprland.options = let
    mkNullOption = (option:
      mkOption option // {
        type = with types;
          nullOr (if option ? "type" then option.type else anything);
        default = null;
      });
    nullableEnable = mkNullOption { type = types.bool; };
  in with types; {
    general = {
      border_size = mkNullOption { type = ints.unsigned; };
      no_border_on_floating = nullableEnable;
      gaps_in = mkNullOption { type = ints.unsigned; };
      gaps_out = mkNullOption { type = ints.unsigned; };
      cursor_inactive_timeout = mkNullOption { type = ints.unsigned; };
      layout = mkNullOption { type = enum [ "dwindle" "master" ]; };
      no_cursor_wraps = nullableEnable;
      no_focus_fallback = nullableEnable;
      apply_sens_to_raw = nullableEnable;
      resize_on_border = nullableEnable;
      extend_border_grab_area = mkNullOption { type = ints.unsigned; };
      hover_icon_on_border = nullableEnable;
      allow_tearing = nullableEnable;
      "col.inactive_border" = mkNullOption { type = str; };
      "col.active_border" = mkNullOption { type = str; };
      "col.no_group_border " = mkNullOption { type = str; };
      "col.no_group_border_active" = mkNullOption { type = str; };
    };

    decoration = {
      rounding = mkNullOption { type = ints.unsigned; };
      active_opacity = mkNullOption { type = float; };
      inactive_opacity = mkNullOption { type = float; };
      fullscreen_opacity = mkNullOption { type = float; };
      drop_shadow = nullableEnable;
      shadow_range = mkNullOption { type = int; };
      shadow_render_power = mkNullOption { type = ints.between 1 4; };
      shadow_ignore_window = nullableEnable;
      "col.shadow" = mkNullOption { type = str; };
      "col.shadow_active" = mkNullOption { type = str; };
      shadow_offset = mkNullOption { type = str; }; # Probably should be a list.
      shadow_scale = mkNullOption { type = float; };
      dim_inactive = nullableEnable;
      dim_strength = mkNullOption { type = float; };
      dim_special = mkNullOption { type = float; };
      dim_around = mkNullOption { type = float; };
      screen_shader = mkNullOption { type = str; };

      blur = {
        enabled = nullableEnable;
        size = mkNullOption { type = ints.unsigned; };
        passes = mkNullOption { type = ints.unsigned; };
        ignore_opacity = nullableEnable;
        new_optimizations = nullableEnable;
        xray = nullableEnable;
        noise = mkNullOption { type = float; };
        contrast = mkNullOption { type = float; };
        brightness = mkNullOption { type = float; };
        special = nullableEnable;
      };
    };

    input = {
      kb_model = mkNullOption { type = str; };
      kb_layout = mkNullOption { type = str; };
      kb_variant = mkNullOption { type = str; };
      kb_options = mkNullOption { type = str; };
      kb_rules = mkNullOption { type = str; };
      kb_file = mkNullOption { type = str; };

      numlock_by_default = nullableEnable;
      repeat_rate = mkNullOption { type = ints.unsigned; };
      repeat_delay = mkNullOption { type = ints.unsigned; };
      sensitivity = mkNullOption { type = float; };
      accel_profile = mkNullOption { type = str; };
      force_no_accel = nullableEnable;
      left_handed = nullableEnable;
      scroll_method = nullableEnable;
      scroll_button = mkNullOption { type = ints.unsigned; };
      scroll_button_lock = nullableEnable;
      natural_scroll = nullableEnable;
      follow_mouse = mkNullOption { type = ints.between 0 3; };
      mouse_refocus = nullableEnable;
      float_switch_override_focus = mkNullOption { type = ints.between 0 2; };
    };

    gestures = {
      workspace_swipe = nullableEnable;
      workspace_swipe_fingers = mkNullOption { type = ints.unsigned; };
      workspace_swipe_distance = mkNullOption { type = ints.unsigned; };
      workspace_swipe_invert = nullableEnable;
      workspace_swipe_min_speed_to_force =
        mkNullOption { type = ints.unsigned; };
      workspace_swipe_cancel_ratio = mkNullOption { type = float; };
      workspace_swipe_create_new = nullableEnable;
      workspace_swipe_direction_lock = nullableEnable;
      workspace_swipe_direction_lock_threshold =
        mkNullOption { type = ints.unsigned; };
      workspace_swipe_forever = nullableEnable;
      workspace_swipe_numbered = nullableEnable;
      workspace_swipe_use_r = nullableEnable;
    };

    group = {
      insert_after_current = nullableEnable;
      focus_removed_window = nullableEnable;
      "col.border_active" = mkNullOption { type = str; };
      "col.border_inactive" = mkNullOption { type = str; };
      "col.border_locked_active" = mkNullOption { type = str; };
      "col.border_locked_inactive" = mkNullOption { type = str; };

      groupbar = {
        font_size = mkNullOption { type = ints.unsigned; };
        gradients = nullableEnable;
        render_titles = nullableEnable;
        scrolling = nullableEnable;
        text_color = mkNullOption { type = str; };
        "col.active" = mkNullOption { type = str; };
        "col.inactive" = mkNullOption { type = str; };
        "col.locked_active" = mkNullOption { type = str; };
        "col.locked_inactive" = mkNullOption { type = str; };
      };

      misc = {
        disable_hyprland_logo = nullableEnable; # You monster.
        disable_splash_rendering = nullableEnable;
        force_hypr_chan = nullableEnable;
        force_default_wallpaper = mkNullOption { type = int; };
        vfr = nullableEnable;
        vrr = mkNullOption { type = ints.between 0 2; };
        mouse_move_enables_dpms = nullableEnable;
        key_press_enables_dpms = nullableEnable;
        always_follow_on_dnd = nullableEnable;
        layers_hog_keyboard_focus = nullableEnable;
        animate_manual_resizes = nullableEnable;
        animate_mouse_windowdragging = nullableEnable;
        disable_autoreload = nullableEnable;
        enable_swallow = nullableEnable;
        swallow_regex = mkNullOption { type = str; };
        swallow_exception_regex = mkNullOption { type = str; };
        focus_on_activate = nullableEnable;
        no_direct_scanout = nullableEnable;
        hide_cursor_on_touch = nullableEnable;
        mouse_move_focuses_monitor = nullableEnable;
        supress_portal_warnings = nullableEnable;
        render_ahead_of_time = nullableEnable;
        render_ahead_safezone = mkNullOption { type = ints.unsigned; };
        cursor_zoom_factor = mkNullOption { type = float; };
        cursor_zoom_rigid = nullableEnable;
        allow_session_lock_restore = nullableEnable;
        background_color = mkNullOption { type = float; };
        close_special_on_empty = mkNullOption { };
        new_window_takes_over_fullscreen =
          mkNullOption { type = ints.between 0 2; };
      };

      xwayland = {
        use_nearest_neighbor = nullableEnable;
        force_zero_scaling = nullableEnable;
      };

      debug = {
        overlay = nullableEnable;
        damage_blink = nullableEnable;
        disable_logs = nullableEnable;
        disable_time = nullableEnable;
        damage_tracking = mkNullOption { type = ints.unsigned; };
        enable_stdout_logs = nullableEnable;
        manual_crash = nullableEnable;
        supress_errors = nullableEnable;
        watchdog_timeout = mkNullOption { type = ints.unsigned; };
      };

      # Layouts:
      dwindle = {
        pseudotile = nullableEnable;
        force_split = mkNullOption { type = ints.between 0 2; };
        preserve_split = nullableEnable;
        smart_split = nullableEnable;
        smart_resizing = nullableEnable;
        permanent_direction_override = nullableEnable;
        special_scale_factor = mkNullOption { type = float; };
        split_width_multiplier = mkNullOption { type = float; };
        no_gaps_when_only = mkNullOption { type = ints.between 0 2; };
        use_active_for_splits = nullableEnable;
        default_split_ratio = mkNullOption { type = float; };
      };

      master = {
        allow_small_split = nullableEnable;
        special_scale_factor = mkNullOption { type = float; };
        mfact = mkNullOption { type = float; };
        new_is_master = nullableEnable;
        new_on_top = nullableEnable;
        no_gaps_when_only = mkNullOption { type = ints.between 0 2; };
        orientation = mkNullOption { type = str; };
        inherit_fullscreen = nullableEnable;
        always_center_master = nullableEnable;
        smart_resizing = nullableEnable;
        drop_at_cursor = nullableEnable;
      };
    };
  };
}
