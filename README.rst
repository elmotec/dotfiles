Dotfiles
--------

Centralizes the dotfiles (e.g. .vimrc) and vimfiles folder on git hub to 
have them immediately available whereever I am. Awesome!

The ``install.bat`` script copies the files using robocopy (for XP). More 
interesting is ``manage.py`` which is an attempt to have the whole process
handled in a self contained and portable script.


Not so obvious git commands
---------------------------

Those commands (and more) were retrieved from the excellent
vimcasts (`http://vimcasts.org/episodes/synchronizing-plugins-with-git-submodules-and-pathogen/`_)

To add a submodule to the bundles (from the dotfiles folder):

.. code::
    git submodule add http://github.com/tpope/vim-fugitive.git vimfiles/bundle/fugitive
    git commit -m "Addded fugitive bundle as a submodule."

To sync the submodule on a new host (from the dotfiles folder):

.. code::
    git submodule init
    git submodule update
    
To upgrade the submodules (from the dotfiles folder):

.. code::
    git submodule foreach git pull origin master

