#!/usr/bin/env python
# encoding: utf-8

"""Manages dot file relationship between home and dotfiles directories."""

# Copyright (c) 2012-2015 Jerome Lecomte
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


__version__ = '0.52'
__author__ = 'Jérôme Lecomte'
__license__ = 'MIT'


import sys
import os.path
import logging
import argparse
import glob
import filecmp
import fnmatch
if sys.version_info < (3, 0, 0):
    import ConfigParser as configparser
else:
    import configparser
import shutil


module = sys.modules['__main__'].__file__
log = logging.getLogger(module)


def match_any_pattern(file_name, patterns):
    """Compares the file name to the patterns.

    Returns false if the patterns list is None or empty.
    """
    assert iter(patterns), "iterable expected"
    assert not isinstance(patterns, str), "string where iterable expected"
    for pattern in patterns:
        if fnmatch.fnmatch(file_name, pattern):
            log.debug("%s matches %s", file_name, pattern)
            return True
    return False


class DotfileError(RuntimeError):
    """Error raised by the Editor class."""
    pass


class DotfileStatus(object):  # pylint: disable=R0903
    """Helper class to hold the status of a dotfile."""
    def __init__(self, name, description):
        self.name = name
        self.description = description

    def __str__(self):
        return self.name

    def __repr__(self):
        return "<{}: {}>".format(self.__class__.__name__, str(self))


class Dotfile(object):  # pylint: disable=R0903
    """Abstraction for a (possible) link between repository and home dir."""

    synced = DotfileStatus('synced', 'symbolic link to dotfile')
    external = DotfileStatus('external', 'symbolic link to other file')
    missing = DotfileStatus('missing', 'not in home directory')
    conflict = DotfileStatus('conflict', 'different from dotfile')
    same = DotfileStatus('same', 'identical but distinct file')
    unmanaged = DotfileStatus('unmanaged', 'not in dotfile directory')

    def __init__(self, name, status=None):
        self.name = name
        self.status = status

    def __repr__(self):
        return "<{}: {}>".format(self.__class__.__name__, vars(self))

    def __eq__(self, rhs):
        return self.name == rhs.name and self.status == rhs.status


class DotfileManager(object):

    """Manages dotfiles."""

    def __init__(self, home_dir=None, dotfiles_dir=None, ignore_patterns=None,
                 difftool=None):
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
        self.ignore_patterns = []
        if ignore_patterns:
            self.ignore_patterns = ignore_patterns
        self.difftool = difftool
        log.info("home dir: %s", self.home_dir)
        log.info("dotfiles dir: %s", self.dotfiles_dir)
        log.debug("ignored patterns: %s", self.ignore_patterns)
        log.debug("difftool: %s", self.difftool)
        assert self.invariants()

    def invariants(self):
        """Self check the class. Called with assert invariants()."""
        assert os.path.exists(self.home_dir)
        assert os.path.isdir(self.home_dir)
        if self.dotfiles_dir:
            assert os.path.exists(self.get_dotfiles_abspath())
            assert os.path.isdir(self.get_dotfiles_abspath())
        return True

    def get_dotfiles_abspath(self):
        """Return the absolute path to the dotfile directory."""
        if os.path.abspath(self.dotfiles_dir) == self.dotfiles_dir:
            return self.dotfiles_dir
        return os.path.join(self.home_dir, self.dotfiles_dir)

    def get_dotfiles_relpath(self):
        """Returns relative path of dotfile with respect to home directory."""
        dotfile_abspath = self.get_dotfiles_abspath()
        home_dir = self.home_dir
        return os.path.relpath(dotfile_abspath, home_dir)

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
            status = Dotfile.missing
        elif not os.path.exists(dotfile_name):
            status = Dotfile.unmanaged
        elif filecmp.cmp(dotfile_name, home_filename):
            status = Dotfile.same
        else:
            status = Dotfile.conflict
        return Dotfile(file_name, status=status)

    def is_ignored(self, file_name, patterns):
        """True if the file_name is to be ignored.

        Compares the file name to the patterns to be matched as well as to
        the ignore patterns (see usage and .dotfilerc).
        """
        if patterns and not match_any_pattern(file_name, patterns):
            return True
        if self.ignore_patterns and \
                match_any_pattern(file_name, self.ignore_patterns):
            return True
        return False

    def get_dotfiles(self, patterns=None):
        """Gets a generator that loops through the dotfiles."""
        if patterns:
            assert iter(patterns), "iterable expected"
            assert not isinstance(patterns, str), "non-string expected"
        seen = set()
        for file_name in os.listdir(self.get_dotfiles_abspath()):
            seen.add(file_name)
            if self.is_ignored(file_name, patterns):
                continue
            yield self.get_dotfile(file_name)
        for file_name in os.listdir(self.home_dir):
            if file_name in seen:
                continue
            if self.is_ignored(file_name, patterns):
                continue
            if file_name.startswith(".") or file_name.endswith("rc"):
                yield self.get_dotfile(file_name)

    def make_symlink(self, dotfile, force=False):
        """Creates a symbolic link in the home directory to the dotfile."""
        can_create_symlink = (dotfile.status in [Dotfile.missing,
                                                 Dotfile.same])
        home_filename = os.path.join(self.home_dir, dotfile.name)
        if force:
            os.unlink(home_filename)  # Remove existing symlink.
            can_create_symlink = True
        if can_create_symlink:
            dotfile_name = os.path.join(self.get_dotfiles_abspath(),
                                        dotfile.name)
            if sys.platform == 'win32':
                is_dir = os.path.isdir(dotfile_name)
                os.symlink(dotfile_name, home_filename, is_dir)
            else:
                os.symlink(dotfile_name, home_filename)
        else:
            log.warning("cannot create symlink: %s is %s",
                        dotfile.name, dotfile.status)

    def sync(self, patterns=None, force=False):
        """Creates a symlink for each file matching patterns.

        Arguments:
        patterns -- list of unix-like file pattern to be matched.
        force -- forces a sync even if the file is already sync'd elsewhere.
        """
        for dotfile in self.get_dotfiles(patterns):
            self.make_symlink(dotfile, force=force)

    def make_copy(self, dotfile, force=False):
        """Creates a copy of the dotfile in the home directory."""
        can_create_copy = (dotfile.status == Dotfile.missing)
        home_filename = os.path.join(self.home_dir, dotfile.name)
        if not can_create_copy and force:
            os.unlink(home_filename)  # Remove existing symlink.
        if can_create_copy:
            dotfile_name = os.path.join(self.get_dotfiles_abspath(),
                                        dotfile.name)
            if sys.platform != 'win32':
                log.warning("it is recommended to use the sync command")
            if os.path.isdir(dotfile_name):
                shutil.copytree(dotfile_name, home_filename)
            else:
                shutil.copy2(dotfile_name, home_filename)
        else:
            log.warning("cannot create copy: %s is %s",
                        dotfile.name, dotfile.status)

    def copy(self, patterns=None):
        """Creates a copy for each file matching patterns."""
        for dotfile in self.get_dotfiles(patterns):
            self.make_copy(dotfile)

    def show_diff(self, dotfile):
        """Shows diff between the dotfile folder and the home directory."""
        if dotfile.status == Dotfile.missing:
            log.warning("%s is missing", dotfile.name)
            return
        home_filename = os.path.join(self.home_dir, dotfile.name)
        if self.difftool:
            import shlex
            import subprocess
            cmd = self.difftool.format(dotfile.name, home_filename)
            #split_cmd = shlex.split(cmd, posix=False)
            try:
                subprocess.check_call(cmd)
            except Exception as err:
                log.error('failed to execute {}: {}'.format(cmd, err))
                raise
        else:
            import difflib
            fromlines = open(dotfile.name).readlines()
            tolines = open(home_filename).readlines()
            diffs = list(difflib.unified_diff(fromlines, tolines))
            if diffs:
                header = "diff {} {}\n".format(dotfile.name, home_filename)
                sys.stdout.write(header)
            sys.stdout.writelines(diffs)


    def diff(self, patterns=None):
        """Diffs each file matching patterns."""
        for dotfile in self.get_dotfiles(patterns):
            self.show_diff(dotfile)


def make_dotfile_manager(args):
    """Creates a DotfileManager instance based on command line arguments."""
    config = configparser.ConfigParser()
    ignore_patterns = None
    difftool = None
    with open(args.config_file) as config_file:
        config.read_file(config_file)
        try:
            ignore_patterns = config['dotfiles']['ignore'].split()
        except KeyError as error:
            log.debug("cannot find dotfiles/ignore configuration in %s: %s",
                      args.config_file, error)
        if args.ignore_patterns:
            ignore_patterns = args.ignore_patterns
        try:
            difftool = config['dotfiles']['difftool']
        except KeyError as error:
            log.debug("cannot find dotfiles/difftool configuration in %s: %s",
                      args.config_file, error)
        if 'difftool' in args and args.difftool:
            difftool = args.difftool
        manager = DotfileManager(ignore_patterns=ignore_patterns,
                                 difftool=difftool)
    return manager


def get_status(args):
    """Displays status of dot files in home directory."""
    manager = make_dotfile_manager(args)
    dotfiles = sorted(manager.get_dotfiles(args.dotfiles),
                      key=lambda df: df.status.name + df.name)
    for dfile in dotfiles:
        print("{:<10} {}".format(str(dfile.status), dfile.name))


def sync(args):
    """Creates symlinks in home directory to files in the dotfile folder."""
    manager = make_dotfile_manager(args)
    manager.sync(args.dotfiles, force=args.force)


def diff(args):
    """Shows differences between dotfile folder and home directory.

    :args: files to process if any.
    """
    manager = make_dotfile_manager(args)
    manager.diff(args.dotfiles)


def copy(args):
    """Copies files in dotfile folder to the home directory.

    Useful for platform that do not support symbolic links.

    :args: files to process if any.
    """
    manager = make_dotfile_manager(args)
    manager.copy(args.dotfiles)


def expand_wildcards(files):
    """Expands wildcards in argument in case it is not done by the shell"""
    all_files = []
    for item in files:
        all_files += glob.glob(item)
    return all_files


def main():
    """Parses command line arguments and dispatch to the correct function."""
    # Main parser.
    parser = argparse.ArgumentParser(description=__doc__,
                                     epilog=None)
    parser.add_argument("-V", "--version", action="version",
                        version="{} {}".format(module, __version__))
    parser.add_argument("-v", "--verbose", dest="verbose_count",
                        action="count", default=0,
                        help="increases log verbosity each time found.")
    parser.add_argument("--dotfilesrc", dest="config_file",
                        metavar="FILE", default=".dotfilesrc",
                        help="specifies configuration file.")
    parser.add_argument("--ignore", dest="ignore_patterns",
                        action='append', metavar="PATTERN",
                        help="patterns to ignore.")
    subparsers = parser.add_subparsers(help="commands to execute")

    # status sub-command.
    status_list = ", ".join(["{} ({})".format(status.name, status.description)
                             for status in Dotfile.__dict__.values()
                             if isinstance(status, DotfileStatus)])
    status_epilog = "Possible statuses include: {}".format(status_list)
    status_parser = subparsers.add_parser('status', help=get_status.__doc__,
                                          epilog=status_epilog)
    status_parser.add_argument('dotfiles', metavar="dotfile", nargs='*',
                               help="dot files to status on.")
    status_parser.set_defaults(func=get_status)

    # sync sub-command.
    sync_parser = subparsers.add_parser('sync', help=sync.__doc__)
    sync_parser.add_argument('dotfiles', metavar="dotfile", nargs='*',
                             help="dot files to sync. Defaults to all.")
    sync_parser.add_argument("-f", "--force", action='store_true',
                             help="forces sync")
    sync_parser.set_defaults(func=sync)

    # copy sub-command.
    copy_parser = subparsers.add_parser('copy', help=copy.__doc__)
    copy_parser.add_argument('dotfiles', metavar="dotfile", nargs='*',
                             help="dot files to copy. Defaults to all.")
    copy_parser.set_defaults(func=copy)

    # diff sub-command.
    diff_parser = subparsers.add_parser('diff', help=diff.__doc__)
    diff_parser.add_argument('--difftool', help="diff tool to use for diff.")
    diff_parser.add_argument('dotfiles', metavar="dotfile", nargs='*',
                             help="dot files to diff. Defaults to all.")
    diff_parser.set_defaults(func=diff)

    args = parser.parse_args(sys.argv[1:])

    # Sets log level to WARN going more verbose for each new -V.
    log.setLevel(max(3 - args.verbose_count, 0) * 10)
    # Dispatch to the args.func defined in set_defaults.
    if 'func' not in args:
        log.error("missing argument. Try -h option.")
        return
    return args.func(args)


if __name__ == "__main__":
    logging.basicConfig(stream=sys.stderr, level=logging.DEBUG,
                        format='%(name)s (%(levelname)s): %(message)s')
    try:
        main()
    finally:
        logging.shutdown()
