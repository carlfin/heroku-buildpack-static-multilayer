#!/usr/bin/env python
import json
import sys
from pathlib import Path

docroot = sys.argv[1]
app = sys.argv[2]
branch = sys.argv[3]

json_file = f'{docroot}/all_paths.json'

# make empty json file directly
if not Path(json_file).is_file():
    Path(json_file).touch()
    with open(json_file, 'w') as f:
        f.write('{}')

# load
data = json.load(open(json_file))

#update
if app not in data:
    data[app] = list()

if branch not in data[app]:
    data[app].push(branch)
    # force reorder always
    data[app].sort()

# store (in same location)
json.dump(data, open(json_file, 'w'), indent=2)
