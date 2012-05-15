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
import logging
import argparse
import difflib
import types
import glob


logger = logging.getLogger(__name__)
logger.addHandler(logging.StreamHandler(sys.stderr))
logger.setLevel(logging.WARNING)


class DotfileError(RuntimeError):
    """Error raised by the Editor class."""
    pass


class DotfileManager(object):
    pass


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
            help="command to exexute")
    parser.add_argument('dotfiles', metavar="dotfile", nargs='+',
            help="dot files to process. See commands.")
    arguments = parser.parse_args(argv[1:])
    setup_logger(int(arguments.verbose_count))
    manager = DotfileManager()
    dotfiles = arguments.dotfiles
    if sys.platform == 'win32':
        files = expand_wildcards(files)
    for dotfile in dotfiles:
        manager.process(dotfile)
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
