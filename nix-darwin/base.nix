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
  };

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
      "localstack/tap/localstack-cli"
    ];

    casks = [
      "devtoys"
      "headlamp"
      "lm-studio"
    ];
  };

  environment.systemPackages = [
    pkgs.bruno
    pkgs.dbeaver-bin
    pkgs.shottr
    pkgs.vlc-bin
  ];
}
