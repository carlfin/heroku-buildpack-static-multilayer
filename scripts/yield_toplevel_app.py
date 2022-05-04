#!/usr/bin/env python

import json
import os

app_structure = json.load(open(f'{os.env["BUILD_DIR"]}/app_structure.json'))

if 'toplevel' in app_structure:
    print(app_structure['toplevel'])
else
    print('toplevel_not_found')
