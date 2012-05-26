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
import fnmatch
import itertools
import configparser


logger = logging.getLogger(__name__)
logger.addHandler(logging.StreamHandler(sys.stderr))
logger.setLevel(logging.WARNING)


class DotfileError(RuntimeError):
    """Error raised by the Editor class."""
    pass


class DotfileStatus(object):
    """Helper class to hold the status of a dotfile."""
    def __init__(self, name, description):
        self.name = name
        self.description = description

    def __str__(self):
        return self.name


class Dotfile(object):
    """Abstraction for a (possible) link between repository and home dir."""

    synced = DotfileStatus('synced', 'symbolic link to dotfile')
    external = DotfileStatus('external', 'symbolic link to other file')
    missing = DotfileStatus('missing', 'not in home directory')
    conflict = DotfileStatus('conflict', 'different from dotfile')
    same = DotfileStatus('same', 'identical but distinct file')

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

    def __init__(self, home_dir=None, dotfiles_dir=None, ignore_files=None):
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
        self.ignore_files = []
        if ignore_files:
            self.ignore_files = ignore_files
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

    def get_dotfile(self, file_name):
        """Retrieves the dotfile for a given file_name."""
        home_filename = os.path.join(self.home_dir, file_name)
        dotfile_name = os.path.join(self.get_dotfiles_abspath(), file_name)
        if os.path.islink(home_filename):
            #if os.path.samefile(target, dotfile_name):  # *ix only !
            target = os.readlink(home_filename)
            if target == dotfile_name:
                status = Dotfile.synced  # absolute symlink
            elif os.path.join(self.home_dir, target) == dotfile_name:
                status = Dotfile.synced  # relative symlink
            else:
                status = Dotfile.external
        elif not os.path.exists(home_filename):
            home_filename = None
            status = Dotfile.missing
        elif filecmp.cmp(dotfile_name, home_filename):
            status = Dotfile.same
        else:
            status = Dotfile.conflict
        return Dotfile(file_name, status=status)

    def ignore(self, file_name, patterns):
        # FIXME: factor file look up in pattern list.
        if patterns:  # patterns to match
            if [pat for pat in patterns if fnmatch.fnmatch(file_name, pat)]:
                return True
        if file_name in self.ignore_files:
            return True
        return False

    def get_dotfiles(self, patterns=None):
        """Gets a generator that loops through the dotfiles."""
        for file_name in os.listdir(self.get_dotfiles_abspath()):
            if self.ignore(file_name, patterns):
                continue
            yield self.get_dotfile(file_name)


def report(args):
    """Displays status of home directory files compared to dotfiles."""
    manager = DotfileManager()
    dotfiles = sorted(manager.get_dotfiles(args.dotfiles),
            key=lambda df: df.status.name + df.name)
    for df in dotfiles:
        print("{:<8} {}".format(df.status, df.name))


def expand_wildcards(files):
    """Expands wildcards in argument in case it is not done by the shell"""
    all_files = []
    for item in files:
        all_files += glob.glob(item)
    return all_files


def main():
    """Parses command line arguments and dispatch to the correct function."""
    # Main parser.
    parser = argparse.ArgumentParser(
            description=__doc__,
            version=__version__,
            epilog=None)
    parser.add_argument("-V", "--verbose", dest="verbose_count",
            action="count", default=0,
            help="increases log verbosity (can be specified multiple times)")
    subparsers = parser.add_subparsers(help="commands to execute")

    # Report sub-command.
    report_epilog = "Possible statuses include: {}".format(
            ", ".join(["{} ({})".format(status.name, status.description) 
                for status in Dotfile.__dict__.values()
                if isinstance(status, DotfileStatus)]))
    report_parser = subparsers.add_parser('report', help=report.__doc__,
            epilog=report_epilog)
    report_parser.add_argument('dotfiles', metavar="dotfile", nargs='*',
            help="dot files to report on.")
    report_parser.set_defaults(func=report)

    args = parser.parse_args(sys.argv[1:])
    
    # Sets log level based on the number of the count of -V
    logger.setLevel(max(4 - args.verbose_count, 0) * 10)
    # Dispatch to the args.func defined in set_defaults.
    return args.func(args)


if __name__ == "__main__":
    logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)
    try:
        main()
    finally:
        logging.shutdown()
