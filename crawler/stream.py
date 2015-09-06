#!/usr/bin/env python

import re
import sys

SHA = re.compile(r'[a-fA-F\d]{32}')
MODS = re.compile(r' (?P<files>\d+) file(.*?),( (?P<insertions>\d+)'
                  r' insertion[s]?\(\+\)[,]?)?( (?P<deletions>\d+) deletion)?')


def print_json_object(c, f, i, d):
    sys.stdout.write('"' + c + '": { ')
    sys.stdout.write('"files": ' + f + ', ')
    sys.stdout.write('"insertions": ' + i + ', ')
    sys.stdout.write('"deletions": ' + d + '},\n')


if __name__ == '__main__':
    previous = ''
    for line in sys.stdin:
        if len(line) == 1:
            continue
        elif not previous:
            previous = line
        elif SHA.match(previous) and SHA.match(line):
            continue
        elif not SHA.match(line):
            m = MODS.match(line)
            files = m.group('files')
            insertions = m.group('insertions') if m.group('insertions') else '0'
            deletions = m.group('deletions') if m.group('deletions') else '0'
            print_json_object(previous.strip('\n'), files, insertions, deletions)
        previous = line
