#!/usr/bin/env python

import json
import os

app_structure = json.load(open(f'{os.env["BUILD_DIR"]}/app_strucuture.json'))

if 'nested' in app_structure:
    print(' '.join(list(map(lambda x: x[0], app_structure['nested']))))
else
    print('nested_not_found')
