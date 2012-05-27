#!/usr/bin/env python

"""Functional tests for py."""

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

import unittest
import tempfile
import shutil
import os.path

from manage import Dotfile, DotfileManager, logger


class DotfileManagerTest(unittest.TestCase):  # pylint: disable=R0904
    """Test case for DotfileManager."""
    def setUp(self):
        """Common initialization for tests.

        Creates a fake home directory to work with and have a dot file
        manager object set up with it.
        """
        self.tmp_dir = tempfile.mkdtemp()
        home_dir = os.path.join(self.tmp_dir, 'home')
        os.mkdir(home_dir)
        dotfiles_dir = os.path.join(home_dir, 'dotfiles')
        os.mkdir(dotfiles_dir)
        self.dfm = DotfileManager(home_dir=home_dir,
                dotfiles_dir=os.path.basename(dotfiles_dir))

    def tearDown(self):
        """Cleans up test home and dotfiles directories."""
        shutil.rmtree(self.tmp_dir)

    def assert_exists(self, path):
        """Helper to assert a path exists."""
        self.assertTrue(os.path.exists(path), "{} does not exist".format(path))

    def assert_dir_exists(self, directory):
        """Helper to assert a path exists and is a directory."""
        self.assert_exists(directory)
        self.assertTrue(os.path.isdir(directory),
                "{} is not a directory".format(directory))

    def create_file(self, dirname, filename, content="blah"):
        """Creates a file."""
        if not os.path.exists(dirname):
            dirname = os.path.join(self.dfm.home_dir, dirname)
        filepath = os.path.join(dirname, filename)
        with open(filepath, 'w') as fh:
            fh.write(content)

    def create_dir(self, dirname, newdirname):
        """Creates a directory."""
        if not os.path.exists(dirname):
            dirname = os.path.join(self.dfm.home_dir, dirname)
        dirpath = os.path.join(dirname, newdirname)
        os.mkdir(dirpath)

    def create_symlink(self, dirname, filename, target):
        """Creates a symlink."""
        filepath = os.path.join(dirname, filename)
        os.symlink(target, filepath)

    def test_home_dir_exists(self):
        """Checks the home directory is set up and is a directory."""
        self.assert_dir_exists(self.dfm.home_dir)

    def test_dotfile_dir_exists(self):
        """Checks the dotfile directory is set up and is a directory."""
        self.assert_dir_exists(self.dfm.get_dotfiles_abspath())

    def test_report_missing(self):
        """Checks status of missing dotfiles in home directory."""
        file_name = '.dotfilerc'
        self.create_file(self.dfm.dotfiles_dir, file_name, "[dotfile]")
        dotfiles = list(self.dfm.get_dotfiles())
        expected_dotfile = Dotfile(file_name, status=Dotfile.missing)
        self.assertSequenceEqual(dotfiles, [expected_dotfile])

    def test_report_unmanaged(self):
        """Checks status of missing dotfiles in home directory."""
        file_name = '.somefile'
        self.create_file(self.dfm.home_dir, file_name)
        dotfiles = list(self.dfm.get_dotfiles())
        expected_dotfile = Dotfile(file_name, status=Dotfile.unmanaged)
        self.assertSequenceEqual(dotfiles, [expected_dotfile])

    def test_report_same(self):
        """Checks status of identical dotfiles between home and checkout."""
        file_name = '.dotfilerc'
        self.create_file(self.dfm.dotfiles_dir, file_name, "[dotfile]")
        self.create_file(self.dfm.home_dir, file_name, "[dotfile]")
        dotfiles = list(self.dfm.get_dotfiles())
        expected_dotfile = Dotfile(file_name, status=Dotfile.same)
        self.assertSequenceEqual(dotfiles, [expected_dotfile])

    def test_report_conflict(self):
        """Checks status of conflicted dotfiles between home and checkout."""
        file_name = '.dotfilerc'
        self.create_file(self.dfm.dotfiles_dir, file_name, "[dotfile]")
        self.create_file(self.dfm.home_dir, file_name, "[dotfiles]")
        dotfiles = list(self.dfm.get_dotfiles())
        expected_dotfile = Dotfile(file_name, status=Dotfile.conflict)
        self.assertSequenceEqual(dotfiles, [expected_dotfile])

    def test_report_external(self):
        """Checks status of dotfiles in home linked to somewhere else."""
        file_name = '.dotfilerc'
        self.create_file(self.dfm.dotfiles_dir, file_name, "[dotfile]")
        self.create_symlink(self.dfm.home_dir, file_name, 'bogus')
        dotfiles = list(self.dfm.get_dotfiles())
        expected_dotfile = Dotfile(file_name, status=Dotfile.external)
        self.assertSequenceEqual(dotfiles, [expected_dotfile])

    def test_report_synced(self):
        """Checks status of synced dotfiles."""
        file_name = '.dotfilerc'
        self.create_file(self.dfm.dotfiles_dir, file_name, "[dotfile]")
        target = os.path.join(self.dfm.dotfiles_dir, file_name)
        self.create_symlink(self.dfm.home_dir, file_name, target)
        dotfiles = list(self.dfm.get_dotfiles())
        expected_dotfile = Dotfile(file_name, status=Dotfile.synced)
        self.assertEqual(dotfiles, [expected_dotfile])

    def test_report_dir_synced(self):
        """Checks status of synced (dot)subdirectories."""
        subdir_name = 'subdir'
        self.create_dir(self.dfm.dotfiles_dir, subdir_name)
        target = os.path.join(self.dfm.dotfiles_dir, subdir_name)
        self.create_symlink(self.dfm.home_dir, subdir_name, target)
        dotfiles = list(self.dfm.get_dotfiles())
        expected_dotfile = Dotfile(subdir_name, status=Dotfile.synced)
        self.assertEqual(dotfiles, [expected_dotfile])

    def test_report_ignored(self):
        """Checks ignore functionality."""
        file_name = '.gitignore'
        self.create_file(self.dfm.dotfiles_dir, file_name, content="*.pyc")
        self.dfm.ignore_patterns = [file_name]
        dotfiles = list(self.dfm.get_dotfiles())
        self.assertEqual(dotfiles, [])

    def test_sync_missing(self):
        """Tests syncing of a missing file."""
        file_name = 'astylerc'
        self.create_file(self.dfm.dotfiles_dir, file_name)
        dotfiles_before = list(self.dfm.get_dotfiles())
        self.assertEqual(dotfiles_before,
                [Dotfile(file_name, status=Dotfile.missing)])
        self.dfm.sync()
        dotfiles_after = list(self.dfm.get_dotfiles())
        self.assertEqual(dotfiles_after,
                [Dotfile(file_name, status=Dotfile.synced)])


if __name__ == '__main__':
    unittest.main()
