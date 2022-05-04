#!/usr/bin/env python

import json
import os
import sys

app = sys.argv[1]

app_structure = json.load(open(f'{os.env["BUILD_DIR"]}/app_strucuture.json'))

if 'nested' in app_structure and app in app_structure['nested']:
    print(app_structure['nested'][app])
else
    print('folder_name_not_found')
