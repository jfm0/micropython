"""
This script reads the input file, compares to existing output and only writes output file if different

This script works with Python 2.6, 2.7, 3.3 and 3.4.
"""

from __future__ import print_function

import sys
import os

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("usage: %s command mode input_filename output_dir output_file" % sys.argv[0])
        sys.exit(2)

    class Args:
        pass

    args = Args()
    args.in_file = sys.argv[1]
    args.out_file = sys.argv[2]

    write_file = True
    if os.path.isfile(args.in_file):
        with open(args.in_file, "r") as f:
            in_file_data = f.read()
            
        if os.path.isfile(args.out_file):
            with open(args.out_file, "r") as f:
                out_file_data = f.read()
            
            if in_file_data == out_file_data:
                write_file = False

    if write_file:
        with open(args.out_file, "w") as f:
            f.write(in_file_data)

