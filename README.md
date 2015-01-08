Dotfiles
--------
Managed by [homesick](https://github.com/technicalpickles/homesick).

To install, run `homesick clone mpriscella/dotfiles`

To update font cache, run `fc-cache -vf ~/.fonts`

To install Vim plugins, run `:PlugInstall` in Vim.

If you encounter an error when installing Plugins, navigate to the repo (`~/.homesick/repos/dotfiles`) and run the following commands:

```
$ git submodule init
$ git submodule update
````

You can overwrite/ add environment specifc variables to the vim, zshrc, and git configurations by creating a new file with the same name as the config file and appending `.local` to the filename. For example, if I wanted to modify my `.vimrc` on a specific machine, I would create and edit the file `.vimrc.local`.
