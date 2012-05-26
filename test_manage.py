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
import os.path

from manage import Dotfile, DotfileManager, logger

class DotfileManagerTest(unittest.TestCase):
    def setUp(self):
        """Common initialization for tests.
        
        Creates a fake home directory to work with and have a dot file
        manager object set up with it.
        """
        tmp_dir = tempfile.mkdtemp()
        home_dir = os.path.join(tmp_dir, 'home')
        os.mkdir(home_dir)
        dotfiles_dir = os.path.join(home_dir, 'dotfiles')
        os.mkdir(dotfiles_dir)
        self.dfm = DotfileManager(home_dir=home_dir,
                dotfiles_dir=os.path.basename(dotfiles_dir))
        self.files = []
        self.directories = [dotfiles_dir, home_dir, tmp_dir]  # order matters!

    def tearDown(self):
        """Cleans up test home and dotfiles directories."""
        for filename in self.files:
            os.remove(filename)
        for directory in self.directories:
            for file in os.listdir(directory):
                logger.warning("found {} in {}. rmdir will fail...".format(
                            file, directory))
            os.rmdir(directory)

    def assertExists(self, path):
        """Helper to assert a path exists."""
        self.assertTrue(os.path.exists(path), "{} does not exist".format(path))

    def assertDirExists(self, directory):
        """Helper to assert a path exists and is a directory."""
        self.assertExists(directory)
        self.assertTrue(os.path.isdir(directory),
                "{} is not a directory".format(directory))

    def create_file(self, dirname, filename, content):
        if not os.path.exists(dirname):
            dirname = os.path.join(self.dfm.home_dir, dirname)
        filepath = os.path.join(dirname, filename)
        with open(filepath, 'w') as fh:
            fh.write(content)
        self.files.insert(0, filepath)

    def create_dir(self, dirname, newdirname):
        if not os.path.exists(dirname):
            dirname = os.path.join(self.dfm.home_dir, dirname)
        dirpath = os.path.join(dirname, newdirname)
        os.mkdir(dirpath)
        self.directories.insert(0, dirpath)

    def create_symlink(self, dirname, filename, target):
        filepath = os.path.join(dirname, filename)
        os.symlink(target, filepath)
        self.files.append(filepath)

    def test_home_dir_exists(self):
        """Checks the home directory is set up and is a directory."""
        self.assertDirExists(self.dfm.home_dir)

    def test_dotfile_dir_exists(self):
        """Checks the dotfile directory is set up and is a directory."""
        self.assertDirExists(self.dfm.get_dotfiles_abspath())

    def test_report_missing(self):
        file_name = '.dotfilerc'
        self.create_file(self.dfm.dotfiles_dir, file_name, "[dotfile]") 
        dotfiles = list(self.dfm.get_dotfiles())
        expected_dotfile = Dotfile(file_name, status=Dotfile.missing)
        self.assertSequenceEqual(dotfiles, [expected_dotfile])

    def test_report_same(self):
        file_name = '.dotfilerc'
        self.create_file(self.dfm.dotfiles_dir, file_name, "[dotfile]") 
        self.create_file(self.dfm.home_dir, file_name, "[dotfile]")
        dotfiles = list(self.dfm.get_dotfiles())
        expected_dotfile = Dotfile(file_name, status=Dotfile.same)
        self.assertSequenceEqual(dotfiles, [expected_dotfile])

    def test_report_conflict(self):
        file_name = '.dotfilerc'
        self.create_file(self.dfm.dotfiles_dir, file_name, "[dotfile]") 
        self.create_file(self.dfm.home_dir, file_name, "[dotfiles]")
        dotfiles = list(self.dfm.get_dotfiles())
        expected_dotfile = Dotfile(file_name, status=Dotfile.conflict) 
        self.assertSequenceEqual(dotfiles, [expected_dotfile])

    def test_report_external(self):
        file_name = '.dotfilerc'
        self.create_file(self.dfm.dotfiles_dir, file_name, "[dotfile]") 
        dotfiles_dir = os.path.basename(self.dfm.home_dir)
        target = os.path.join(dotfiles_dir, file_name)
        self.create_symlink(self.dfm.home_dir, file_name, 'bogus')
        dotfiles = list(self.dfm.get_dotfiles())
        expected_dotfile = Dotfile(file_name, status=Dotfile.external) 
        self.assertSequenceEqual(dotfiles, [expected_dotfile])

    def test_report_synced(self):
        file_name = '.dotfilerc'
        self.create_file(self.dfm.dotfiles_dir, file_name, "[dotfile]") 
        target = os.path.join(self.dfm.dotfiles_dir, file_name)
        self.create_symlink(self.dfm.home_dir, file_name, target)
        dotfiles = list(self.dfm.get_dotfiles())
        expected_dotfile = Dotfile(file_name, status=Dotfile.synced) 
        self.assertEqual(dotfiles, [expected_dotfile])

    def test_report_dir_synced(self):
        subdir_name = 'subdir'
        self.create_dir(self.dfm.dotfiles_dir, subdir_name)
        target = os.path.join(self.dfm.dotfiles_dir, subdir_name)
        self.create_symlink(self.dfm.home_dir, subdir_name, target)
        dotfiles = list(self.dfm.get_dotfiles())
        expected_dotfile = Dotfile(subdir_name, status=Dotfile.synced) 
        self.assertEqual(dotfiles, [expected_dotfile])

    def test_report_ignored(self):
        file_name = '.gitignore'
        self.create_file(self.dfm.dotfiles_dir, file_name, "*.pyc") 
        self.dfm.ignore_files = [ file_name ]
        dotfiles = list(self.dfm.get_dotfiles())
        self.assertEqual(dotfiles, [])


        
if __name__ == '__main__':
    unittest.main()


