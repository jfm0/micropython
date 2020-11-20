"""
This script processes the output from the C preprocessor and extracts all
qstr. Each qstr is transformed into a qstr definition of the form 'Q(...)'.

This script works with Python 2.6, 2.7, 3.3 and 3.4.
"""

from __future__ import print_function

import re
import subprocess
import sys
import io
import os


# Extract MP_QSTR_FOO macros.
_MODE_QSTR = "qstr"

# Extract MP_COMPRESSED_ROM_TEXT("") macros.  (Which come from MP_ERROR_TEXT)
_MODE_COMPRESS = "compress"


def preprocess():
    if any(src in args.dependencies for src in args.changed_sources):
        sources = args.sources
    elif any(args.changed_sources):
        sources = args.changed_sources
    else:
        sources = args.sources
    csources = []
    cxxsources = []
    for source in sources:
        if source.endswith(".cpp"):
            cxxsources.append(source)
        else:
            csources.append(source)
    try:
        os.makedirs(os.path.dirname(args.output[0]))
    except OSError:
        pass
    with open(args.output[0], "w") as out_file:
        if csources:
            subprocess.check_call(args.pp + args.cflags + csources, stdout=out_file)
        if cxxsources:
            subprocess.check_call(args.pp + args.cxxflags + cxxsources, stdout=out_file)


def write_out(fname, output):
    # Only write the file if we need to
    if output:
        for m, r in [("/", "__"), ("\\", "__"), (":", "@"), ("..", "@@")]:
            fname = fname.replace(m, r)
        file_path = args.output_dir + "/" + fname + "." + args.mode
        # Check if the file contents changed from last time
        write_file = True
        if os.path.isfile(file_path):
            with open(file_path, "r") as f:
                existing_data = f.read()
            if existing_data == output:
                write_file = False

        if write_file:
            with open(args.output_file, "w") as f:
                f.write("this file is modified when any split file is modified.")
            with open(file_path, "w") as f:
                f.write("\n".join(output) + "\n")


def process_file(f):
    re_line = re.compile(r"#[line]*\s\d+\s\"([^\"]+)\"")
    if args.mode == _MODE_QSTR:
        re_match = re.compile(r"MP_QSTR_[_a-zA-Z0-9]+")
    elif args.mode == _MODE_COMPRESS:
        re_match = re.compile(r'MP_COMPRESSED_ROM_TEXT\("([^"]*)"\)')
    output = []
    last_fname = None
    for line in f:
        if line.isspace():
            continue
        # match gcc-like output (# n "file") and msvc-like output (#line n "file")
        if line.startswith(("# ", "#line")):
            m = re_line.match(line)
            assert m is not None
            fname = m.group(1)
            if os.path.splitext(fname)[1] not in [".c", ".cpp"]:
                continue
            if fname != last_fname:
                write_out(last_fname, output)
                output = []
                last_fname = fname
            continue
        for match in re_match.findall(line):
            if args.mode == _MODE_QSTR:
                name = match.replace("MP_QSTR_", "")
                output.append("Q(" + name + ")")
            elif args.mode == _MODE_COMPRESS:
                output.append(match)

    if last_fname:
        write_out(last_fname, output)
    return ""


def cat_together():
    import glob
    import hashlib

    hasher = hashlib.md5()
    all_lines = []
    outf = open(args.output_dir + "/out", "wb")
    for fname in glob.glob(args.output_dir + "/*." + args.mode):
        with open(fname, "rb") as f:
            lines = f.readlines()
            all_lines += lines
    all_lines.sort()
    all_lines = b"\n".join(all_lines)
    outf.write(all_lines)
    outf.close()
    hasher.update(all_lines)
    new_hash = hasher.hexdigest()
    old_hash = None
    try:
        with open(args.output_file + ".hash") as f:
            old_hash = f.read()
    except IOError:
        pass
    mode_full = "QSTR"
    if args.mode == _MODE_COMPRESS:
        mode_full = "Compressed data"
    print(new_hash)
    print(old_hash)
    if old_hash != new_hash:
        print(mode_full, "updated")
        try:
            # rename below might fail if file exists
            os.remove(args.output_file)
        except:
            pass
        os.rename(args.output_dir + "/out", args.output_file)
        with open(args.output_file + ".hash", "w") as f:
            f.write(new_hash)
    else:
        print(mode_full, "not updated")


if __name__ == "__main__":
    if len(sys.argv) < 6:
        print("usage: %s command mode input_filename output_dir output_file" % sys.argv[0])
        sys.exit(2)

    class Args:
        pass

    args = Args()
    args.command = sys.argv[1]

    if args.command == "pp":
        named_args = {
            s: []
            for s in [
                "pp",
                "output",
                "cflags",
                "cxxflags",
                "sources",
                "changed_sources",
                "dependencies",
            ]
        }

        for arg in sys.argv[1:]:
            if arg in named_args:
                current_tok = arg
            else:
                named_args[current_tok].append(arg)

        if not named_args["pp"] or len(named_args["output"]) != 1:
            print("usage: %s %s ..." % (sys.argv[0], " ... ".join(named_args)))
            sys.exit(2)

        for k, v in named_args.items():
            setattr(args, k, v)

        preprocess()
        sys.exit(0)

    args.mode = sys.argv[2]
    args.input_filename = sys.argv[3]  # Unused for command=cat
    args.output_dir = sys.argv[4]
    args.output_file = sys.argv[5]  # Unused for command=split

    if args.mode not in (_MODE_QSTR, _MODE_COMPRESS):
        print("error: mode %s unrecognised" % sys.argv[2])
        sys.exit(2)

    try:
        os.makedirs(args.output_dir)
    except OSError:
        pass

    if args.command == "split":
        with io.open(args.input_filename, encoding="utf-8") as infile:
            process_file(infile) # args.output_file is created if any new or modified file created

    if args.command == "cat":
        cat_together()
