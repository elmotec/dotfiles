#!/usr/bin/env sh

typeset module=`basename $0 .sh`
typeset srcdir=`dirname $0`
srcdir=`(cd $srcdir && pwd)`
typeset home=${HOME:?"missing environment variable"}

# Creates relative symlinks to dotfiles contents.
ls -a $srcdir | egrep -v "(\.git|README.rst|\..*\.swp|.*\.log|\.|\.\.|$module\..*)$" | sed "s|.*|ln -s $srcdir/& $HOME/.|g" | sh
