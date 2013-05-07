# pretty print variables
from pprint import pprint
alias pp pprint(vars(%1))

# return to debugger after fatal exception (Python cookbook 14.5):
import pdb
import sys

def info(type, value, tb):
    if hasattr(sys, 'ps1') or not sys.stderr.isatty():
        sys.__excepthook__(type, value, tb)
    import traceback, pdb
    traceback.print_exception(type, value, tb)
    print
    pdb.pm()

sys.excepthook = info

# Clean up
try:
    del pprint
    del info
    del pdb
    del sys
except NameError:
    pass
