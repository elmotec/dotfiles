#!/usr/bin/env python
# vim: set fileencoding=utf-8

"""Functional tests for py."""

# Copyright (c) 2012-2015 Jérôme Lecomte
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

import logging
import pathlib as pl
import shutil
import tempfile
import unittest
import unittest.mock as mock

from manage import Dotfile, DotfileManager


class DotfileManagerTest(unittest.TestCase):  # pylint: disable=R0904

    """Test case for DotfileManager."""

    def setUp(self):
        """Common initialization for tests.

        Creates a fake home directory to work with and have a dot file
        manager object set up with it.
        """
        self.tmp_dir = tempfile.mkdtemp()
        home_dir = pl.Path(self.tmp_dir) / 'home'
        home_dir.mkdir()
        dotfiles_dir = home_dir / 'dotfiles'
        dotfiles_dir.mkdir()
        self.dfm = DotfileManager(home_dir=home_dir,
                                  dotfiles_dir=dotfiles_dir)
        logging.disable(logging.WARNING)

    def tearDown(self):
        """Cleans up test home and dotfiles directories."""
        shutil.rmtree(self.tmp_dir)

    def assert_exists(self, path):
        """Helper to assert a path exists."""
        self.assertTrue(path.exists(), "{} does not exist".format(path))

    def assert_dir_exists(self, directory):
        """Helper to assert a path exists and is a directory."""
        self.assert_exists(directory)
        self.assertTrue(directory.is_dir(), "{} is not a directory".format(directory))

    def create_dir(self, dirname, newdirname):
        """Creates a directory."""
        if not dirname.exists():
            dirname = self.dfm.home_dir / dirname
        dirpath = dirname / newdirname
        dirpath.mkdir()

    def create_symlink(self, dirname, filename, target):
        """Creates a symlink."""
        filepath = dirname / filename
        filepath.symlink_to(target)

    def test_home_dir_exists(self):
        """Checks the home directory is set up and is a directory."""
        self.assert_dir_exists(self.dfm.home_dir)

    def test_dotfile_dir_exists(self):
        """Checks the dotfile directory is set up and is a directory."""
        self.assert_dir_exists(self.dfm.get_dotfiles_abspath())

    def test_status_dir_synced(self):
        """Checks status of synced (dot)subdirectories."""
        subdir_name = 'subdir'
        self.create_dir(self.dfm.dotfiles_dir, subdir_name)
        target = self.dfm.dotfiles_dir / subdir_name
        self.create_symlink(self.dfm.home_dir, subdir_name, target)
        dotfiles = list(self.dfm.get_dotfiles())
        expected_dotfile = Dotfile(subdir_name, status=Dotfile.synced)
        self.assertEqual(dotfiles, [expected_dotfile])


class DotfileManagerSingleFileTest(DotfileManagerTest):
    """Test in the context of a single file."""

    def setUp(self):
        """Initializes test with file_name."""
        super().setUp()
        self.file_name = 'testrc'

    def create_file(self, dirname, filename, content):
        """Creates a file."""
        if not dirname.exists():
            dirname = self.dfm.home_dir / dirname
        filepath = dirname / filename
        with open(filepath, 'w') as fh:
            fh.write(content)

    def test_status_missing(self):
        """Checks status of missing dotfiles in home directory."""
        self.create_file(self.dfm.dotfiles_dir, self.file_name, "[dotfile]")
        dotfiles = list(self.dfm.get_dotfiles())
        expected_dotfile = Dotfile(self.file_name, status=Dotfile.missing)
        self.assertSequenceEqual(dotfiles, [expected_dotfile])

    def notest_status_unmanaged(self):
        """Checks status of missing dotfiles in home directory."""
        self.create_file(self.dfm.home_dir, self.file_name, 'blah')
        dotfiles = list(self.dfm.get_dotfiles())
        expected_dotfile = Dotfile(self.file_name, status=Dotfile.unmanaged)
        self.assertSequenceEqual(dotfiles, [expected_dotfile])

    def test_status_same(self):
        """Checks status of identical dotfiles between home and checkout."""
        self.create_file(self.dfm.dotfiles_dir, self.file_name, "[dotfile]")
        self.create_file(self.dfm.home_dir, self.file_name, "[dotfile]")
        dotfiles = list(self.dfm.get_dotfiles())
        expected_dotfile = Dotfile(self.file_name, status=Dotfile.same)
        self.assertSequenceEqual(dotfiles, [expected_dotfile])

    def test_status_conflict(self):
        """Checks status of conflicted dotfiles between home and checkout."""
        self.create_file(self.dfm.dotfiles_dir, self.file_name, "[dotfile]")
        self.create_file(self.dfm.home_dir, self.file_name, "[dotfiles]")
        dotfiles = list(self.dfm.get_dotfiles())
        expected_dotfile = Dotfile(self.file_name, status=Dotfile.conflict)
        self.assertSequenceEqual(dotfiles, [expected_dotfile])

    def test_status_external(self):
        """Checks status of dotfiles in home linked to somewhere else."""
        self.create_file(self.dfm.dotfiles_dir, self.file_name, "[dotfile]")
        self.create_symlink(self.dfm.home_dir, self.file_name, 'bogus')
        dotfiles = list(self.dfm.get_dotfiles())
        expected_dotfile = Dotfile(self.file_name, status=Dotfile.external)
        self.assertSequenceEqual(dotfiles, [expected_dotfile])

    def test_status_synced(self):
        """Checks status of synced dotfiles."""
        self.create_file(self.dfm.dotfiles_dir, self.file_name, "[dotfile]")
        target = self.dfm.dotfiles_dir / self.file_name
        self.create_symlink(self.dfm.home_dir, self.file_name, target)
        dotfiles = list(self.dfm.get_dotfiles())
        expected_dotfile = Dotfile(self.file_name, status=Dotfile.synced)
        self.assertEqual(dotfiles, [expected_dotfile])

    def test_status_ignored(self):
        """Checks ignore functionality."""
        self.create_file(self.dfm.dotfiles_dir, self.file_name, "blah")
        self.dfm.ignore_patterns = ["*rc"]
        dotfiles = list(self.dfm.get_dotfiles())
        self.assertEqual(dotfiles, [])

    def test_sync_missing(self):
        """Tests syncing of a missing file."""
        self.create_file(self.dfm.dotfiles_dir, self.file_name, 'blah')
        dotfiles_before = list(self.dfm.get_dotfiles())
        self.assertEqual(dotfiles_before,
                         [Dotfile(self.file_name, status=Dotfile.missing)])
        self.dfm.sync()
        dotfiles_after = list(self.dfm.get_dotfiles())
        self.assertEqual(dotfiles_after,
                         [Dotfile(self.file_name, status=Dotfile.synced)])

    def test_nosync_conflict(self):
        """Tests syncing of a missing file."""
        self.create_file(self.dfm.dotfiles_dir, self.file_name, 'blah')
        self.create_file(self.dfm.home_dir, self.file_name, 'not blah')
        dotfiles_before = list(self.dfm.get_dotfiles())
        self.assertEqual(dotfiles_before,
                         [Dotfile(self.file_name, status=Dotfile.conflict)])
        self.dfm.sync()
        dotfiles_after = list(self.dfm.get_dotfiles())
        self.assertEqual(dotfiles_after,
                         [Dotfile(self.file_name, status=Dotfile.conflict)])

    def test_copy_missing(self):
        """Tests copy of a missing file."""
        self.create_file(self.dfm.dotfiles_dir, self.file_name, 'blah')
        dotfiles_before = list(self.dfm.get_dotfiles())
        self.assertEqual(dotfiles_before,
                         [Dotfile(self.file_name, status=Dotfile.missing)])
        self.dfm.copy()
        dotfiles_after = list(self.dfm.get_dotfiles())
        self.assertEqual(dotfiles_after,
                         [Dotfile(self.file_name, status=Dotfile.same)])

    def test_difftool(self):
        """Test difftool option."""
        self.dfm.difftool = 'gvim -d {} {}'
        self.create_file(self.dfm.dotfiles_dir, self.file_name, 'blah')
        self.create_file(self.dfm.home_dir, self.file_name, 'other')
        dotfile = next(self.dfm.get_dotfiles())
        with mock.patch('subprocess.check_call') as check_call:
            self.dfm.show_diff(dotfile)
            dotfile = self.file_name
            homefile = self.dfm.home_dir / self.file_name
            check_call.assert_called_once_with(['gvim', '-d', dotfile, str(homefile)])


if __name__ == '__main__':
    unittest.main()
