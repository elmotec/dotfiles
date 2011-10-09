Centralizes the dotfiles (e.g. .vimrc) and vimfiles folder on git hub to 
have them immediately available whereever I am. Awesome!

The install.bat script copies the files using robocopy. It seemed to be
the best compromise between portability (with XP in mind) and convenience.

The prefered way (if possible) is to rely on the install.sh which creates
symlinks so that modifications to the file shows up in the .git controlled
dotfiles directory.

