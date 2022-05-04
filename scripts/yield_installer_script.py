#!/usr/bin/env python

import json
import os

app_strucuture = json.load(open(f'{os.env["BUILD_DIR"]}/app_strucuture.json'))

if 'integration' in app_structure and app_structure['integration']:
    print('installer_integration.sh')
else:
    print('installer.sh')
