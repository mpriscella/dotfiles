{config, ...}:
# Karabiner-Elements: macOS-only, so it lives entirely in the nix-darwin layer.
# This module owns both the app (a Homebrew cask — it needs a system extension)
# and its declaratively-managed config.
#
# NOTE: the config is written as a read-only symlink into the Nix store, so the
# Karabiner GUI can no longer edit it — the config lives here. On first install
# you must still approve the driver extension and grant Input Monitoring in
# System Settings > Privacy & Security (Nix can't click those). If the GUI ever
# clobbers the symlink with a plain file, `rm` it and rebuild to restore it.
{
  # Merges with the cask list in base.nix.
  homebrew.casks = ["karabiner-elements"];

  home-manager.users.${config.system.primaryUser}.home.file.".config/karabiner/karabiner.json".text = builtins.toJSON {
    global.check_for_updates_on_startup = false;
    global.show_in_menu_bar = false;
    profiles = [
      {
        name = "Default";
        selected = true;
        # Baked in so the GUI never prompts for keyboard type — that prompt is
        # what makes Karabiner write to (and thus clobber) the managed symlink.
        virtual_hid_keyboard.keyboard_type_v2 = "ansi";
        # Caps Lock → Control must be done HERE, not in System Settings >
        # Keyboard > Modifier Keys. Once Karabiner grabs a keyboard it re-emits
        # events through its virtual keyboard, so macOS applies modifier remaps
        # against the virtual device (Caps Lock unchanged) and the real
        # keyboard's setting is bypassed. Doing it in Karabiner works regardless.
        simple_modifications = [
          {
            from.key_code = "caps_lock";
            to = [{key_code = "left_control";}];
          }
        ];
        # The Keychron Q1 (QMK) enumerates as TWO HID interfaces sharing the
        # same vendor/product id: a keyboard-only one (modified by default) and
        # a keyboard+pointing one. Karabiner ignores pointing-capable devices by
        # default, but on this board the letter keys come through that combo
        # interface — so complex mods silently don't apply (e.g. left_option+h
        # passes through unmapped) unless we force `ignore = false` for it. See
        # pqrs-org/Karabiner-Elements#3065 / #3015.
        #
        # Do NOT set `ignore_vendor_events = true` here. Karabiner drops
        # `apple_vendor_top_case` events (Mission Control, brightness, etc.) for
        # NON-Apple devices when that flag is on. In Mac mode the Keychron
        # emulates those Apple keys but reports a Keychron vendor id, so it
        # counts as non-Apple — enabling the flag silently kills F3/Mission
        # Control. Leaving it at the default (false) lets the fn row pass through.
        devices = [
          # Keychron Q1 (QMK)
          {
            identifiers = {
              vendor_id = 13364; # 0x3434
              product_id = 263; # 0x0107
              is_keyboard = true;
              is_pointing_device = true;
            };
            ignore = false;
          }
          # Vortex POK3R (for me — this is my POK3R). Its bottom-left cluster is
          # Control · Win · Alt, which macOS maps to Control · ⌘ · ⌥ — so ⌘ and ⌥
          # sit in the opposite positions from a Mac keyboard (where ⌘ is next to
          # the space bar). Swap them for this board only via per-device
          # simple_modifications so the built-in keyboard and Keychron are
          # untouched. Control already matches (corner on both layouts).
          #
          # NOTE: these IDs identify the Holtek controller chip (vendor 0x04D9 =
          # Holtek, product 0x0141), NOT the POK3R specifically — the firmware
          # reports generic "USB Keyboard" strings. Any other Holtek-based board
          # could share them, so this rule isn't guaranteed unique to the POK3R.
          {
            identifiers = {
              vendor_id = 1241; # 0x04D9 (Holtek controller, not POK3R-specific)
              product_id = 321; # 0x0141
              is_keyboard = true;
            };
            simple_modifications = [
              {
                from.key_code = "left_command";
                to = [{key_code = "left_option";}];
              }
              {
                from.key_code = "left_option";
                to = [{key_code = "left_command";}];
              }
            ];
          }
        ];
        complex_modifications.rules = [
          {
            # Scoped to the POK3R via device_if — the Keychron already produces
            # ~/` as expected, so we leave it untouched.
            description = "POK3R: Escape → tilde/backtick (Shift → ~, Left Option → `)";
            manipulators = let
              pok3rCondition = [
                {
                  type = "device_if";
                  identifiers = [
                    {
                      vendor_id = 1241; # 0x04D9 (Holtek controller)
                      product_id = 321; # 0x0141
                    }
                  ];
                }
              ];
            in [
              # Shift+Escape → ~ (shifted grave). Match shift as mandatory and
              # re-emit it so the shifted glyph is produced.
              {
                type = "basic";
                from = {
                  key_code = "escape";
                  modifiers = {
                    mandatory = ["shift"];
                    optional = ["any"];
                  };
                };
                to = [
                  {
                    key_code = "grave_accent_and_tilde";
                    modifiers = ["left_shift"];
                  }
                ];
                conditions = pok3rCondition;
              }
              # Left Option+Escape → ` (plain grave). Drop the option modifier by
              # not re-emitting it.
              {
                type = "basic";
                from = {
                  key_code = "escape";
                  modifiers = {
                    mandatory = ["left_option"];
                    optional = ["any"];
                  };
                };
                to = [{key_code = "grave_accent_and_tilde";}];
                conditions = pok3rCondition;
              }
            ];
          }
          {
            description = "Left Option+hjkl → arrow keys";
            manipulators =
              map (m: {
                type = "basic";
                from = {
                  key_code = m.from;
                  modifiers = {
                    mandatory = ["left_option"];
                    optional = ["any"];
                  };
                };
                to = [{key_code = m.to;}];
              }) [
                {
                  from = "h";
                  to = "left_arrow";
                }
                {
                  from = "j";
                  to = "down_arrow";
                }
                {
                  from = "k";
                  to = "up_arrow";
                }
                {
                  from = "l";
                  to = "right_arrow";
                }
              ];
          }
          {
            # Grabbing the Keychron for the rule above also seizes its Apple
            # media row (Mission Control, brightness, …), which rides an
            # `apple_vendor_top_case` usage Karabiner can't re-emit once grabbed.
            # Workaround: the Keychron's top row is remapped to plain F-keys in
            # VIA/QMK, and we regenerate the macOS media functions here (Karabiner
            # posts these fine through its virtual keyboard). Scoped to the
            # Keychron via device_if so the built-in keyboard's F-row is untouched.
            description = "Keychron: F-row → macOS media keys";
            manipulators =
              map (m: {
                type = "basic";
                from.key_code = m.from;
                to = [{key_code = m.to;}];
                conditions = [
                  {
                    type = "device_if";
                    identifiers = [
                      {
                        vendor_id = 13364;
                        product_id = 263;
                      }
                    ];
                  }
                ];
              }) [
                {
                  from = "f1";
                  to = "display_brightness_decrement";
                }
                {
                  from = "f2";
                  to = "display_brightness_increment";
                }
                {
                  from = "f3";
                  to = "mission_control";
                }
                {
                  from = "f4";
                  to = "launchpad";
                }
                {
                  from = "f5";
                  to = "illumination_decrement";
                }
                {
                  from = "f6";
                  to = "illumination_increment";
                }
                {
                  from = "f7";
                  to = "rewind";
                }
                {
                  from = "f8";
                  to = "play_or_pause";
                }
                {
                  from = "f9";
                  to = "fastforward";
                }
                {
                  from = "f10";
                  to = "mute";
                }
                {
                  from = "f11";
                  to = "volume_decrement";
                }
                {
                  from = "f12";
                  to = "volume_increment";
                }
              ];
          }
          {
            # POK3R: Option+d → volume up, Option+s → volume down. Karabiner
            # applies simple modifications BEFORE complex modifications, so the
            # per-device ⌘/⌥ swap above has already run by the time this rule
            # evaluates: on this board `left_option` is emitted by the physical
            # Win-position key — i.e. the key sitting in the Mac Option slot
            # (Control · Option · Command). Matching left_option therefore lands
            # on the Option key as laid out. Scoped to the POK3R via device_if.
            description = "POK3R: Option+d/s → volume up/down";
            manipulators =
              map (m: {
                type = "basic";
                from = {
                  key_code = m.from;
                  modifiers = {
                    mandatory = ["left_option"];
                    optional = ["any"];
                  };
                };
                to = [{key_code = m.to;}];
                conditions = [
                  {
                    type = "device_if";
                    identifiers = [
                      {
                        vendor_id = 1241;
                        product_id = 321;
                      }
                    ];
                  }
                ];
              }) [
                {
                  from = "d";
                  to = "volume_increment";
                }
                {
                  from = "s";
                  to = "volume_decrement";
                }
              ];
          }
        ];
      }
    ];
  };
}
