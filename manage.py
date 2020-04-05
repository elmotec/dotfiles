#!/usr/bin/env python3
# encoding: utf-8

"""Manages dot file relationship between home and dotfiles directories."""

# Copyright (c) 2012-2019 Jerome Lecomte
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


__version__ = '0.6'
__author__ = 'Jérôme Lecomte'
__license__ = 'MIT'


import sys
assert sys.version_info >= (3, 8) or sys.platfom != "win32", \
    "program requires Python 3.8 for Windows"
import os.path
import logging
import argparse
import glob
import filecmp
import fnmatch
import configparser
import shutil
if sys.platform == 'win32':
    import _winapi


module = sys.modules['__main__'].__file__
log = logging.getLogger(module)


def match_any_pattern(name, patterns):
    """Compares the file name to the patterns.

    Returns false if the patterns list is None or empty.
    """
    assert iter(patterns), "iterable expected"
    assert not isinstance(patterns, str), "string where iterable expected"
    for pattern in patterns:
        if fnmatch.fnmatch(name, pattern):
            log.debug("%s matches %s", name, pattern)
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
        self.home_dir = home_dir or os.path.expanduser("~")
        self.dotfiles_dir = os.getcwd()
        if dotfiles_dir:
            self.dotfiles_dir = dotfiles_dir
        self.ignore_patterns = []
        if ignore_patterns:
            self.ignore_patterns = ignore_patterns
        self.difftool = difftool
        log.debug("home directory: %s", self.home_dir)
        log.debug("dotfiles directory: %s", self.dotfiles_dir)
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
        home_name = os.path.join(self.home_dir, file_name)
        dotfile_name = os.path.join(self.get_dotfiles_abspath(), file_name)
        # Starting Python 3.8, detects junctions on Windows
        if os.path.realpath(home_name) == os.path.realpath(dotfile_name):
            status = Dotfile.synced
        elif not os.path.exists(home_name):
            status = Dotfile.missing
        elif os.path.isdir(home_name) and os.path.isdir(dotfile_name):
            status = Dotfile.same 
        elif not os.path.exists(dotfile_name):
            status = Dotfile.unmanaged
        elif filecmp.cmp(dotfile_name, home_name):
            status = Dotfile.same
        else:
            status = Dotfile.conflict
        return Dotfile(file_name, status=status)

    def is_ignored(self, name, patterns):
        """True if the name is to be ignored.

        Compares the file name to the patterns to be matched as well as to
        the ignore patterns (see usage and .dotfilerc).
        """
        if patterns and not match_any_pattern(name, patterns):
            return True
        if self.ignore_patterns and \
                match_any_pattern(name, self.ignore_patterns):
            return True
        return False

    def get_dotfiles(self, patterns=None):
        """Gets a generator that loops through the dotfiles."""
        if patterns:
            assert iter(patterns), "iterable expected"
            assert not isinstance(patterns, str), "non-string expected"
            # Remove .\ prefix if any because relpath does not have it.
            patterns = [pat.replace(".\\", "") for pat in patterns]
        seen = set()
        top_dir = "."
        for root, dirs, files in os.walk(top_dir):
            relroot = os.path.relpath(root)
            if root == top_dir:
                for file in files:
                    dotlessfile = file.replace(".\\", "")
                    if not self.is_ignored(dotlessfile, patterns):
                        log.info("processing %s ...", relroot)
                        yield self.get_dotfile(dotlessfile)
                        continue
            elif not self.is_ignored(relroot, patterns):
                log.info("processing %s ...", relroot)
                yield self.get_dotfile(relroot)
                continue
            log.debug("ignored %s", relroot)
        return

    def make_symlink(self, dotfile, force=False):
        """Creates a symbolic link in the home directory to the dotfile."""
        can_create_symlink = (dotfile.status in [Dotfile.missing,
                                                 Dotfile.same])
        home_filename = os.path.join(self.home_dir, dotfile.name)
        if force:
            log.info("deleting %s ...", home_filename)
            os.unlink(home_filename)  # Remove existing symlink.
            log.debug("%s deleted", home_filename)
            can_create_symlink = True
        if can_create_symlink:
            dotfile_name = os.path.join(self.get_dotfiles_abspath(),
                                        dotfile.name)
            log.info("creating symlink %s -> %s ...", dotfile_name, home_filename)
            if sys.platform == 'win32':
                is_dir = os.path.isdir(dotfile_name)
                if is_dir:
                    log.debug("using windows junction ...")
                    _winapi.CreateJunction(dotfile_name, home_filename)
                else:
                    try:
                        log.debug("using symlink (on windows) ...")
                        os.symlink(dotfile_name, home_filename, is_dir)
                    except OSError as err:
                        log.error('failed to create symlink: %s', err)
                        log.error('see https://stackoverflow.com/questions/26787872/')
                        log.info('revert to copy')
                        self.make_copy(dotfile, force=force)
            else:
                log.debug("using symlink ...")
                os.symlink(dotfile_name, home_filename)
            log.debug("symlink %s -> %s created", dotfile_name, home_filename)
        else:
            log.warning("cannot create symlink: %s status is %s",
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
        if os.path.isdir(dotfile.name):
            log.debug("%s is a directory", dotfile.name)
            return
        home_filename = os.path.join(self.home_dir, dotfile.name)
        if self.difftool:
            import shlex
            import subprocess
            cmd = self.difftool.format(dotfile.name, home_filename)
            log.info(cmd)
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
        manager = DotfileManager(home_dir=args.home_dir,
                                 ignore_patterns=ignore_patterns,
                                 difftool=difftool)
        return manager


def get_status(args):
    """Displays status of dot files in home directory."""
    manager = make_dotfile_manager(args)
    dotfiles = sorted(manager.get_dotfiles(args.dotfiles),
                      key=lambda df: df.status.name + df.name)
    for dfile in dotfiles:
        file_or_dir = 'F'
        if os.path.isdir(dfile.name):
            file_or_dir = 'D' 
        status = str(dfile.status)
        if args.diffs and status in ['synced', 'same']:
            continue
        print("{} {:<10} {}".format(file_or_dir, status, dfile.name))


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
    home_dir = os.path.expanduser("~")
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
    parser.add_argument("--home-dir", dest="home_dir", default=home_dir,
                        help="change the home directory")
    subparsers = parser.add_subparsers(help="commands to execute")

    # status sub-command.
    status_list = ", ".join(["{} ({})".format(status.name, status.description)
                             for status in Dotfile.__dict__.values()
                             if isinstance(status, DotfileStatus)])
    status_epilog = "Possible statuses include: {}".format(status_list)
    status_parser = subparsers.add_parser('status', help=get_status.__doc__,
                                          epilog=status_epilog)
    status_parser.add_argument("-d", "--diffs", dest="diffs",
                               action="store_true",
                               help="only show differences.")
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
