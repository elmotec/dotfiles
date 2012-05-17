#!/usr/bin/env python

"""Manages dot file relationship between home and dotfiles directories."""

# Copyright (c) 2012 Jerome Lecomte
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


__version__ = '0.50'
__author__ = 'Jerome Lecomte'
__license__ = 'MIT'


import sys
import os.path
import logging
import argparse
import difflib
import types
import glob
import filecmp
import itertools


logger = logging.getLogger(__name__)
logger.addHandler(logging.StreamHandler(sys.stderr))
logger.setLevel(logging.WARNING)


class DotfileError(RuntimeError):
    """Error raised by the Editor class."""
    pass


class Dotfile(object):
    """Abstraction for a (possible) link between repository and home dir."""

    synced = 'synced'  # symbolic link to dotfile
    external = 'external'  # symbolic link to other file
    missing = 'missing'  # not in home directory
    conflict = 'conflict'  # different from dotfile
    same = 'same'  # identical but distinct file

    def __init__(self, name, status=None):
        self.name = name
        self.status = status

    def __repr__(self):
        return "<{}: {}>".format(self.__class__.__name__, vars(self))

    def __eq__(self, rhs):
        return self.name == rhs.name and \
                self.status == rhs.status


class DotfileManager(object):
    """Manages dotfiles."""

    def __init__(self, home_dir=None, dotfiles_dir=None):
        """Sets variable that will be needed by the manager.

        Post conditions:
        self.home_dir exists and is a directory.
        self.dotfiles_dir exists and is a directory.
        """
        self.home_dir = os.path.expanduser("~")
        if home_dir:
            self.home_dir = home_dir
        self.dotfiles_dir = os.getcwd()
        if dotfiles_dir:
            self.dotfiles_dir = dotfiles_dir
        assert(self.invariants())

    def invariants(self):
        """Self check the class. Called with assert(invariants())."""
        assert(os.path.exists(self.home_dir))
        assert(os.path.isdir(self.home_dir))
        if self.dotfiles_dir:
            assert(os.path.exists(self.get_dotfiles_abspath()))
            assert(os.path.isdir(self.get_dotfiles_abspath()))
        return True

    def get_dotfiles_abspath(self):
        """Return the absolute path to the dotfile directory"""
        if os.path.abspath(self.dotfiles_dir) == self.dotfiles_dir:
            return self.dotfiles_dir
        return os.path.join(self.home_dir, self.dotfiles_dir)

    def get_dotfiles(self):
        """Gets a generator that loops through the dotfiles."""
        for filename in os.listdir(self.get_dotfiles_abspath()):
            home_filename = os.path.join(self.home_dir, filename)
            dotfile_name = os.path.join(
                    self.get_dotfiles_abspath(), filename)
            if os.path.islink(home_filename):
                #if os.path.samefile(target, dotfile_name): # *ix only ! 
                target = os.readlink(home_filename)
                if target == dotfile_name:
                    status = Dotfile.synced
                else:
                    status = Dotfile.external
            elif not os.path.exists(home_filename):
                home_filename = None
                status = Dotfile.missing
            elif filecmp.cmp(dotfile_name, home_filename):
                status = Dotfile.same
            else:
                status = Dotfile.conflict
            yield Dotfile(filename, status=status)


class DotfilesInterface(object):
    """Interface for the DotfileManager. Provides higher level commands."""
    def __init__(self, manager):
        self.manager = manager

    def get_valid_commands(self):
        """Introspectively list the methods other than __init__ and itself"""
        import inspect
        command_methods = [ name for (name, value) in inspect.getmembers(
            self, predicate=inspect.ismethod)
                if name not in ('__init__', 'get_valid_commands')]
        return command_methods

    def help(self):
        """This help"""
        print("Valid commands are:")
        commands = list(self.get_valid_commands())
        for command in self.get_valid_commands():
            print("{:<8}: {}".format(command,
                getattr(self, command).__doc__))

    def report(self):
        """Displays the status of the dotfiles"""
        dotfiles = sorted(self.manager.get_dotfiles(), 
                key=lambda df: df.status + df.name)
        for status, dotfiles in itertools.groupby(
                dotfiles, lambda df: df.status):
            if dotfiles:
                print("{}:".format(status))
                print("".join(["  {}\n".format(df.name) for df in dotfiles]))

def get_verbosity(verbose_count):
    """Helper to convert a count of verbosity level to a logging level."""
    assert(isinstance(verbose_count, int))
    if verbose_count < 0:
        verbose_count = 0
    if verbose_count > 4:
        verbose_count = 4
    levels = [logging.ERROR, logging.WARNING,
            logging.INFO, logging.DEBUG]
    return levels[verbose_count]


def setup_logger(verbose_count):
    """Sets up a logger object for this script."""
    logging.basicConfig(stream=sys.stderr)
    verbosity = get_verbosity(verbose_count)
    if (verbosity > 0):
        logger.setLevel(verbosity)
        logger.info("logger level set to {}".format(verbosity))


def expand_wildcards(files):
    """Expands wildcards in argument in case it is not done by the shell."""
    all_files = []
    for item in files:
        all_files += glob.glob(item)
    return all_files


def command_line(argv):
    """Main command line handler."""
    parser = argparse.ArgumentParser(
            description=__doc__,
            version=__version__,
            epilog=None)
    parser.add_argument("-V", "--verbose", dest="verbose_count",
            action="count", default=0,
            help="increases log verbosity (can be specified multiple times)")
    parser.add_argument('command', metavar="command",
            help="command to execute")
    parser.add_argument('dotfiles', metavar="dotfile", nargs='*',
            help="dot files to process. See commands.")
    arguments = parser.parse_args(argv[1:])
    setup_logger(int(arguments.verbose_count))
    manager = DotfileManager()
    dotfiles = arguments.dotfiles
    if sys.platform == 'win32':
        dotfiles = expand_wildcards(dotfiles)
    if arguments.command == 'help':
        DotfilesInterface(manager).help()
    if arguments.command == 'report':
        DotfilesInterface(manager).report()
    return 1


if __name__ == "__main__":
    logging.basicConfig(stream=sys.stderr)
    os_status = 1
    try:
        command_line(sys.argv)
        os_status = 0
    finally:
        logging.shutdown()
    sys.exit(os_status)
