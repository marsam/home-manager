{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.programs.alacritty;

  keyBinding = types.submodule {
    options = {
      key = mkOption {
        type = types.str;
        description = ''
          Key to Bind.
        '';
      };

      mods = mkOption {
        type = types.str;
        description = ''
          Mod key(s).
        '';
      };

      action = mkOption {
        type = types.nullOr (types.enum [
          "Paste"
          "PasteSelection"
          "Copy"
          "IncreaseFontSize"
          "DecreaseFontSize"
          "ResetFontSize"
          "ScrollPageUp"
          "ScrollPageDown"
          "ScrollToTop"
          "ScrollToBottom"
          "ClearHistory"
          "Hide"
          "Quit"
          "ClearLogNotice"
          "SpawnNewInstance"
          "None"
        ]);
        default = null;
        description = ''
          Action to execute.
        '';
      };

      mode = mkOption {
        type = types.nullOr (types.enum [
          "~AppCursor"
          "AppCursor"
          "~AppKeypad"
          "AppKeypad"
        ]);
        default = null;
        description = ''
          Mode.
        '';
      };
    };
  };
  configOptions = recursiveUpdate (
    (optionalAttrs (cfg.shell != {}) { shell = cfg.shell; }) //
    (optionalAttrs (cfg.window != {}) { window = cfg.window; }) //
    (optionalAttrs (cfg.keyBindings != []) { key_bindings = cfg.keyBindings; })
  ) cfg.extraConfig;

in

{
  meta.maintainers = [ maintainers.marsam ];

  options.programs.alacritty = {
    enable = mkEnableOption "Alacritty terminal";

    package = mkOption {
      type = types.package;
      default = pkgs.alacritty;
      defaultText = "pkgs.alacritty";
      description = "Alacritty package to install.";
    };

    shell = {
      program = mkOption {
        type = types.str;
        default = "/bin/bash";
        description = ''
          Shell program path.
        '';
      };

      args = mkOption {
        type = types.listOf types.str;
        default = [];
        example = "--login";
        description = ''
          Arguments to pass to shell program.
        '';
      };
    };

    window = {
      dimensions = {
        columns = mkOption {
          type = types.int;
          default = 0;
          description = ''
            Number of columns in the window.
          '';
        };

        lines = mkOption {
          type = types.int;
          default = 0;
          description = ''
            Number of lines in the window.
          '';
        };
      };
      padding = {
        x = mkOption {
          type = types.int;
          default = 2;
          description = ''
            Horizontal padding around the window, in pixels.
          '';
        };
        y = mkOption {
          type = types.int;
          default = 2;
          description = ''
            Vertical padding around the window, in pixels.
          '';
        };
      };
      decorations = mkOption {
        type = types.enum ([ "none" "full" ] ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [ "transparent" "buttonless" ]);
        default = "full";
        description = ''
          Window decorations
          <variablelist>
            <varlistentry>
              <term><literal>none</literal></term>
              <listitem>
                <para>Neither borders nor title bar.</para>
              </listitem>
            </varlistentry>
            <varlistentry>
              <term><literal>full</literal></term>
              <listitem>
                <para>Borders and title bar.</para>
              </listitem>
            </varlistentry>
            <varlistentry>
              <term><literal>transparent</literal></term>
              <listitem>
                <para>
                  <emphasis role="bold">macOS only</emphasis>.
                  Title bar, transparent background and title bar buttons.
                </para>
              </listitem>
            </varlistentry>
            <varlistentry>
              <term><literal>buttonless</literal></term>
              <listitem>
                <para>
                  <emphasis role="bold">macOS only</emphasis>.
                  Title bar, transparent background, but no title bar buttons
                </para>
              </listitem>
            </varlistentry>
          </variablelist>
        '';
      };
    };
    scrolling = {
      history = mkOption {
        type = types.int;
        default = 10000;
        description = ''
          Maximum number of lines in the scrollback buffer.
          Specifying '0' will disable scrolling.
        '';
      };
      multiplier = mkOption {
        type = types.int;
        default = 3;
        description = ''
          Number of lines the viewport will move for every line scrolled.
        '';
      };
      fauxMultiplier = mkOption {
        type = types.int;
        default = 3;
        description = ''
          Number of lines the terminal should scroll when the alternate screen
          buffer is active.
          Specifying '0' will disable faux scrolling.
        '';
      };
      autoScroll = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Scroll to the bottom when new text is written to the terminal.
        '';
      };
    };
    colors = {
      primary = {
        background = mkOption {
          type = types.str;
          default = "0x000000";
          description = "Background color";
        };
        foreground = mkOption {
          type = types.str;
          default = "0xeaeaea";
          description = "Foreground color";
        };
      };
    };
    visualBell = {
      animation = mkOption {
        type = types.enum [
          "Ease"
          "EaseOut"
          "EaseOutSine"
          "EaseOutQuad"
          "EaseOutCubic"
          "EaseOutQuart"
          "EaseOutQuint"
          "EaseOutExpo"
          "EaseOutCirc"
          "Linear"
        ];
        default = "EaseOutExpo";
        description = ''
          Visual bell animation.
        '';
      };
      duration = mkOption {
        type = types.int;
        default = 0;
        description = ''
          Visual bell duration in milliseconds.
          Specifying a "duration" of "0" will disable the visual bell.
        '';
      };
      color = mkOption {
        type = types.str;
        default = "0xffffff";
        description = ''
          Visual bell color.
        '';
      };
    };
    backgroundOpacity = mkOption {
      type = types.float;
      default = 1.0;
      description = ''
        Window opacity as a floating point number from 0.0 to 1.0.
        The value 0.0 is completely transparent and 1.0 is opaque.
      '';
    };
    cursor = {
      style = mkOption {
        type = types.enum [ "Block" "Underline" "Beam" ];
        default = "Block";
        description = "The cursor style.";
      };
      unfocusedHollow = mkOption {
        type = types.bool;
        default = true;
        description = "If this is true, the cursor will be rendered as a hollow box when the window is not focused.";
      };
    };

    keyBindings = mkOption {
      type = types.listOf keyBinding;
      default = [];
      description = ''
        Keybinds.
      '';
    };

    extraConfig = mkOption {
      type = types.attrs;
      default = {};
      description = ''
        Any extra options. These will be merged into the other options set.
      '';
      example = literalExample ''
        {
          font = {
            normal = {
              family = "PragmataPro Liga";
              style = "Regular";
            };
            size = 15.0;
          };
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."alacritty/alacritty.yml" = mkIf (configOptions != {}) {
      text = generators.toYAML {} configOptions;
    };
  };
}
