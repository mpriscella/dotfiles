{...}: {
  # Host overrides for a Mac that runs long, unattended agent sessions rather
  # than being a daily driver. Layered on top of base.nix.

  # Never idle-sleep on AC power, so agents keep working with the display
  # off. The display still sleeps on its normal schedule.
  # (power.restartAfterPowerFailure is deliberately left unset: MacBooks
  # report it as unsupported and systemsetup fails activation.)
  power.sleep.computer = "never";

  # Idle sleep is not lid sleep: closing the lid still sleeps the Mac unless
  # an external display is attached. nix-darwin has no option for that, so
  # set pmset's global disablesleep flag, which also blocks lid-close sleep.
  #
  # Trade-offs: it applies on battery too (an unplugged, closed Mac stays
  # awake until the battery runs out) and runs warmer with the lid shut.
  # Removing this block does NOT undo it; run `sudo pmset -a disablesleep 0`.
  system.activationScripts.postActivation.text = ''
    echo "disabling system sleep (including lid close)..." >&2
    pmset -a disablesleep 1
  '';
}
