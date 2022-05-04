#!/usr/bin/env python

import json
import os

app_structure = json.load(open(f'{os.environ["BUILD_DIR"]}/app_structure.json'))

if 'integration' in app_structure and app_structure['integration']:
    print('installer_integration.sh')
else:
    print('installer.sh')
