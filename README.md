# Dotfiles

[![Open in Dev Containers](https://img.shields.io/static/v1?label=Dev%20Containers&message=Open&color=blue&logo=visualstudiocode)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/mpriscella/dotfiles)

My personal dotfiles. Feel free to borrow from or use them, but your mileage
may vary.

## Installation

```shell
$ ./dotfiles.sh install
```

## Usage in Development Containers

Add the following value to your VSCode's `settings.json` file.

```json
{
  "dotfiles.repository": "mpriscella/dotfiles"
}
```

## Troubleshooting

### zsh startup taking an abnormally long time

If `zsh` is taking a long time to start up, the startup script can be profiled
using [zprof](https://zsh.sourceforge.io/Doc/Release/Zsh-Modules.html#The-zsh_002fzprof-Module).
Add the following lines to the beginning and end of `.zshrc`. The next time `zsh`
runs, the profiling results will be printed to standard output.

```shell
zmodload zsh/zprof

# zsh script

zprof
```

## TODO
- [ ] For terraform files, if I type `gh` in normal mode, I want the following comment inserted.
- [ ] On nvim save, I should trim whitespace
