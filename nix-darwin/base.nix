{
  config,
  pkgs,
  ...
}: {
  nix = {
    enable = true;

    settings = {
      # Determinate enabled these by default; upstream + nix-darwin must
      # set them explicitly or flake commands break.
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["@admin"];
    };

    optimise.automatic = true;
  };

  # Garbage collection by generation count rather than age. nix.gc only offers
  # `--delete-older-than`, which can collect the generation whose files are
  # actually linked into $HOME: the profile is bumped before activation runs,
  # so a switch that fails to activate leaves the live links pointing at an
  # older generation that then ages out, and they dangle.
  #
  # Runs as root so it covers the system profile (which carries Home Manager)
  # as well as per-user ones. --no-gcroots leaves direnv/`result` roots alone,
  # matching what nix-collect-garbage did. Same schedule nix.gc defaulted to.
  launchd.daemons.nh-clean = {
    command = "${pkgs.nh}/bin/nh clean all --keep 5 --no-gcroots --elevation-strategy none";
    serviceConfig = {
      RunAtLoad = false;
      StartCalendarInterval = [
        {
          Weekday = 7;
          Hour = 3;
          Minute = 15;
        }
      ];
      StandardOutPath = "/var/log/nh-clean.log";
      StandardErrorPath = "/var/log/nh-clean.log";
    };
  };

  # Allow Touch ID in place of a password for sudo (darwin-rebuild, nh, etc.).
  security.pam.services.sudo_local.touchIdAuth = true;

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  programs.fish.enable = true;

  system = {
    defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyleSwitchesAutomatically = true;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };

      dock = {
        autohide = true;
        show-recents = false;
        tilesize = 47;
        wvous-br-corner = 14; # bottom-right hot corner: Quick Note
      };

      finder = {
        FXPreferredViewStyle = "Nlsv"; # list view
        ShowStatusBar = true;
        ShowExternalHardDrivesOnDesktop = true;
        ShowHardDrivesOnDesktop = false;
        ShowRemovableMediaOnDesktop = true;
      };

      loginwindow = {
        GuestEnabled = false;
      };

      menuExtraClock = {
        ShowAMPM = true;
        ShowDate = 0; # only when space allows
        ShowDayOfWeek = true;
      };

      screencapture = {
        location = "/Users/${config.system.primaryUser}/Screenshots";
      };

      trackpad = {
        Clicking = false;
        Dragging = false;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = false;
      };

      WindowManager = {
        GloballyEnabled = false; # Stage Manager off
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
    stateVersion = 6;
  };

  homebrew = {
    enable = true;

    onActivation = {
      # Upgrades are deliberate: run `brew update && brew upgrade` manually.
      autoUpdate = false;
      cleanup = "uninstall";
      upgrade = false;
      # Homebrew >= 5.x refuses `--cleanup` in non-interactive runs unless a
      # force flag is passed; nix-darwin doesn't add one yet.
      extraFlags = ["--force-cleanup"];
    };

    brews = [
      "floci-io/floci/floci"
    ];

    casks = [
      "devtoys"
      "ghostty"
      {
        name = "headlamp";
        args.no_quarantine = true;
      }
      "obsidian"
      "sweet-home3d"
      "utm"
    ];
  };

  environment.systemPackages = [
    pkgs.bruno
    pkgs.dbeaver-bin
    pkgs.drawio
    pkgs.shottr
    pkgs.vlc-bin
  ];
}
