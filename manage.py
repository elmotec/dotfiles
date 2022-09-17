#!/usr/bin/env python3

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
assert sys.version_info >= (3, 8) or sys.platform != "win32", \
    "program requires Python 3.8 for Windows"
import argparse
import configparser
import difflib
import filecmp
import fnmatch
import logging
import os
import pathlib as pl
import shlex
import shutil
import subprocess
import typing
if sys.platform == 'win32':
    import _winapi


module = sys.modules['__main__'].__file__  # pylint: disable=no-member
log = logging.getLogger(module)


class DotfileError(RuntimeError):
    """Error raised by the Editor class."""


class DotfileStatus:  # pylint: disable=R0903
    """Helper class to hold the status of a dotfile."""
    def __init__(self, name, description):
        self.name = name
        self.description = description

    def __str__(self):
        return self.name

    def __repr__(self):
        return f"<{self.__class__.__name__} {self}>"


class Dotfile:  # pylint: disable=R0903
    """Abstraction for a (possible) link between repository and home dir."""

    synced = DotfileStatus('synced', 'symbolic link to dotfile')
    external = DotfileStatus('external', 'symbolic link to file other than dotfile')
    missing = DotfileStatus('missing', 'not in home directory')
    conflict = DotfileStatus('conflict', 'different from dotfile')
    same = DotfileStatus('same', 'identical but distinct file')
    unmanaged = DotfileStatus('unmanaged', 'not in dotfile directory')

    def __init__(self, name, status=None):
        self.name = name
        self.status = status

    def __repr__(self):
        return f"<{self.__class__.__name__}: {vars(self)}>"

    def __eq__(self, rhs):
        return self.name == rhs.name and self.status == rhs.status


def read_all_file(file_name: str, encoding: str = "utf-8") -> typing.List[str]:
    """Read and return all the lines in a file."""
    with open(file_name, encoding=encoding) as fh:
        return fh.readlines()
    return []


class DotfileManager:

    """Manages dotfiles."""

    def __init__(self, home_dir=None, dotfiles_dir=None, ignore_patterns=None,
                 difftool=None):
        """Sets variable that will be needed by the manager.

        Post conditions:
        self.home_dir exists and is a directory.
        self.dotfiles_dir exists and is a directory.
        """
        self.home_dir = pl.Path(home_dir or pl.Path.home())
        self.dotfiles_dir = pl.Path(dotfiles_dir or pl.Path.cwd())
        self.ignore_patterns = []
        if ignore_patterns:
            self.ignore_patterns = [self.dotfiles_dir / ip for ip in ignore_patterns]
        self.difftool = difftool
        log.info("home directory: %s", self.home_dir)
        log.info("dotfiles directory: %s", self.dotfiles_dir)
        log.info("ignored patterns: %s", self.ignore_patterns)
        log.info("difftool: %s", self.difftool)
        assert self.invariants()

    def invariants(self):
        """Self check the class. Called with assert invariants()."""
        assert self.home_dir.exists()
        assert self.home_dir.is_dir()
        if self.dotfiles_dir:
            assert self.get_dotfiles_abspath().exists()
            assert self.get_dotfiles_abspath().is_dir()
        return True

    def get_dotfiles_abspath(self):
        """Return the absolute path to the dotfile directory."""
        if self.dotfiles_dir.absolute() == self.dotfiles_dir:
            return self.dotfiles_dir
        return pl.Path.home() / self.dotfiles_dir

    def get_dotfiles_relpath(self):
        """Returns relative path of dotfile with respect to home directory."""
        dotfile_abspath = self.get_dotfiles_abspath()
        home_dir = self.home_dir
        return dotfile_abspath.relative_to(home_dir)

    def get_dotfile(self, file_name: pl.Path):
        """Retrieves the Dotfile for a given file_name."""
        relative = file_name.relative_to(self.dotfiles_dir)
        home_name = self.home_dir / relative
        dotfile_name = self.get_dotfiles_abspath() / file_name
        # Starting Python 3.8, detects junctions on Windows.
        if home_name.resolve() == dotfile_name.resolve():
            status = Dotfile.synced
        # Home file is a symlink but not resolved to the correct dotfile.
        elif home_name.is_symlink():
            status = Dotfile.external
        elif not home_name.exists():
            status = Dotfile.missing
        elif home_name.is_dir() and dotfile_name.is_dir():
            status = Dotfile.same
        elif not dotfile_name.exists():
            status = Dotfile.unmanaged
        elif filecmp.cmp(str(dotfile_name), str(home_name)):
            status = Dotfile.same
        else:
            status = Dotfile.conflict
        return Dotfile(str(relative), status=status)

    def get_dotfiles(self, targets=None):
        """Gets a generator that loops through the dotfiles.

        targets:
            Can be files or directories.

        """
        if targets is None:
            targets = ["."]
        assert iter(targets), "iterable expected"
        assert not isinstance(targets, str), "non-string expected"
        target_files = []
        targets = [self.dotfiles_dir / target for target in targets]
        for target in targets:
            if pl.Path(target).is_dir():
                files = pl.Path(target).glob("**/*")
            else:
                files = [target]
            target_files += files
        for target_file in target_files:
            log.debug("%s ...", target_file)
            str_target_file = str(target_file)
            match = [fnmatch.fnmatch(str_target_file, ipat) for ipat in self.ignore_patterns]
            if any(match):
                log.debug("ignored %s", target_file)
                continue
            log.debug("processing %s ...", target_file)
            yield self.get_dotfile(target_file)


    def make_symlink(self, dotfile, force=False):
        """Creates a symbolic link in the home directory to the dotfile."""
        can_create_symlink = (dotfile.status in [Dotfile.missing, Dotfile.same])
        home_filename = self.home_dir / dotfile.name
        if force:
            log.info("deleting %s ...", home_filename)
            os.unlink(home_filename)  # Remove existing symlink.
            log.debug("%s deleted", home_filename)
            can_create_symlink = True
        if can_create_symlink:
            dotfile_name = self.get_dotfiles_abspath() / dotfile.name
            log.info("creating symlink %s -> %s ...", dotfile_name, home_filename)
            if sys.platform == 'win32':
                is_dir = dotfile_name.is_dir()
                if is_dir:
                    log.debug("using windows junction ...")
                    try:
                        _winapi.CreateJunction(str(dotfile_name), str(home_filename))
                    except FileExistsError as err:
                        log.error('failed to create link to %s: %s', home_filename, err)
                        raise
                else:
                    try:
                        log.debug("using symlink (on windows) ...")
                        home_filename.symlink_to(dotfile_name, is_dir)
                    except OSError as err:
                        log.error('failed to create symlink: %s', err)
                        log.error('see https://stackoverflow.com/questions/26787872/')
                        log.info('revert to copy')
                        self.make_copy(dotfile, force=force)
            else:
                log.debug("using symlink ...")
                os.symlink(dotfile_name, home_filename)
            log.debug("symlink %s -> %s created", dotfile_name, home_filename)
        elif dotfile.status == Dotfile.synced:
            log.debug("symlink %s already exists", dotfile.name)
        else:
            log.warning("cannot create symlink: %s status is %s",
                        dotfile.name, dotfile.status)

    def sync(self, targets=None, force=False):
        """Creates a symlink for each file matching patterns.

        Arguments:
        patterns -- list of unix-like file pattern to be matched.
        force -- forces a sync even if the file is already sync'd elsewhere.
        """
        for dotfile in self.get_dotfiles(targets):
            self.make_symlink(dotfile, force=force)

    def make_copy(self, dotfile, force=False):
        """Creates a copy of the dotfile in the home directory."""
        can_create_copy = (dotfile.status == Dotfile.missing)
        home_filename = self.home_dir / dotfile.name
        if not can_create_copy and force:
            os.unlink(home_filename)  # Remove existing symlink.
        if can_create_copy:
            dotfile_name = self.get_dotfiles_abspath() / dotfile.name
            if sys.platform != 'win32':
                log.warning("it is recommended to use the sync command")
            if dotfile_name.is_dir():
                shutil.copytree(dotfile_name, home_filename)
            else:
                shutil.copy2(dotfile_name, home_filename)
        else:
            log.warning("cannot create copy: %s is %s",
                        dotfile.name, dotfile.status)

    def copy(self, targets=None):
        """Creates a copy for each file matching patterns."""
        for dotfile in self.get_dotfiles(targets):
            self.make_copy(dotfile)

    def show_diff(self, dotfile):
        """Shows diff between the dotfile folder and the home directory."""
        if dotfile.status == Dotfile.missing:
            log.warning("%s is missing", dotfile.name)
            return
        if pl.Path(dotfile.name).is_dir():
            log.debug("%s is a directory", dotfile.name)
            return
        home_filename = self.home_dir / dotfile.name
        if self.difftool:
            cmd = self.difftool.format(str(dotfile.name), str(home_filename))
            log.info(cmd)
            try:
                cmd_split = shlex.split(cmd)
                subprocess.check_call(cmd_split)
            except Exception as err:
                log.error('failed to execute %s: %s', cmd, err)
                raise
        else:
            fromlines = read_all_file(dotfile.name)
            tolines = read_all_file(home_filename)
            diffs = list(difflib.unified_diff(fromlines, tolines))
            if diffs:
                header = f"diff {dotfile.name} {home_filename}\n"
                sys.stdout.write(header)
            sys.stdout.writelines(diffs)


    def diff(self, targets=None):
        """Diffs each file matching targets."""
        for dotfile in self.get_dotfiles(targets):
            self.show_diff(dotfile)


def make_dotfile_manager(args):
    """Creates a DotfileManager instance based on command line arguments."""
    config = configparser.ConfigParser()
    ignore_patterns = None
    difftool = None
    with open(args.config_file, encoding="utf-8") as config_file:
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
        manager = DotfileManager(home_dir=pl.Path(args.home_dir),
                                 ignore_patterns=ignore_patterns,
                                 difftool=difftool)
        return manager


def get_status(args):
    """Displays status of dot files in home directory."""
    manager = make_dotfile_manager(args)
    dotfiles = sorted(manager.get_dotfiles(args.dotfiles),
                      key=lambda df: df.status.name + str(df.name))
    for dfile in dotfiles:
        file_or_dir = 'F'
        if (manager.dotfiles_dir / dfile.name).is_dir():
            file_or_dir = 'D'
        status = str(dfile.status)
        if args.diffs and status in ['synced', 'same']:
            continue
        print(f"{file_or_dir} {status:<10} {dfile.name}")


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


def main() -> None:
    """Parses command line arguments and dispatch to the correct function."""
    # Main parser.
    home_dir = pl.Path.home()
    parser = argparse.ArgumentParser(description=__doc__,
                                     epilog=None)
    parser.add_argument("-V", "--version", action="version",
                        version=f"{module} {__version__}")
    parser.add_argument("-v", "--verbose", dest="verbose_count",
                        action="count", default=0,
                        help="increases log verbosity each time found.")
    parser.add_argument("--dotfilesrc", dest="config_file",
                        metavar="FILE", default=".dotfilesrc",
                        help="specifies configuration file.")
    parser.add_argument("--ignore", dest="ignore_patterns",
                        action='append', metavar="PATTERN",
                        help="patterns to ignore.")
    parser.add_argument("--home-dir", dest="home_dir", default=str(home_dir),
                        help="change the home directory")
    subparsers = parser.add_subparsers(help="commands to execute")

    # status sub-command.
    status_list = ", ".join([f"{status.name} ({status.description})"
                             for status in Dotfile.__dict__.values()
                             if isinstance(status, DotfileStatus)])
    status_epilog = f"Possible statuses include: {status_list}"
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
    args.func(args)


if __name__ == "__main__":
    logging.basicConfig(stream=sys.stderr, level=logging.DEBUG,
                        format='%(name)s (%(levelname)s): %(message)s')
    main()
