#!/usr/bin/env python

import json
import os

app_structure = json.load(open(f'{os.environ["BUILD_DIR"]}/app_structure.json'))

if 'nested' in app_structure:
    print(' '.join(list(map(lambda x: x, app_structure['nested']))))
else:
    print('nested_not_found')
