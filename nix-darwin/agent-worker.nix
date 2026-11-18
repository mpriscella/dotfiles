{...}: {
  # Host overrides for a Mac that runs long, unattended agent sessions rather
  # than being a daily driver. Layered on top of base.nix.

  # Never sleep the machine, so agents keep working with the lid open and the
  # display off. The display still sleeps on its normal schedule.
  # (power.restartAfterPowerFailure is deliberately left unset: MacBooks
  # report it as unsupported and systemsetup fails activation.)
  power.sleep.computer = "never";
}
