Dotfiles
--------

Centralizes the dotfiles (e.g. .vimrc) and vimfiles folder on git hub to 
have them immediately available whereever I am. Awesome!

The `install.bat` script copies the files using robocopy (for XP). More 
interesting is `manage.py` which is an attempt to have the whole process
handled in a self contained and portable script.


Windows
-------

Run the following commands with elevated privileges in the home directory:
```powershell
New-Item -Type SymbolicLink -Target .\dotfiles\.vim -Path .vim
New-Item -Type SymbolicLink -Target .\.vim -Path vimfiles
```


Not so obvious git commands
---------------------------

More info available in the excellent vimcasts episode at
http://vimcasts.org/episodes/synchronizing-plugins-with-git-submodules-and-pathogen/


To add a submodule to the bundles (from the dotfiles folder):

```bash
git submodule add http://github.com/tpope/vim-fugitive.git vimfiles/bundle/fugitive
git commit -m "Addded fugitive bundle as a submodule."
```

To sync the submodule on a new host (from the dotfiles folder):

```bash
git submodule init
git submodule update
```

To upgrade the submodules (from the dotfiles folder):

```bash
git submodule foreach git pull origin master
```

TODO
====

- Handle config files located in %APPDATA% instead of %HOME%
- Manage Windows symlink in a way that does not require extra symlink privileges (junction for directories and copy for files). See https://cygwin.com/cygwin-ug-net/using-cygwinenv.html

