Dotfiles
--------
Managed by [homesick](https://github.com/technicalpickles/homesick).

To install, run `homesick clone mpriscella/dotfiles`

To update font cache, run `fc-cache -vf ~/.fonts`

To install Vim plugins, run `:PluginInstall` in Vim.

If you encounter an error when installing Plugins, navigate to the repo (`~/.homesick/repos/dotfiles`) and run the following commands:

```
$ git submodule init
$ git submodule update
````


You can overwrite/ add environment specific options the vim configuration by entering config options in `.vimrc.local`

You can overwrite/ add environment specific options the zshrc configuration by entering config options in `.zshrc.local`
