#!/usr/bin/env python
import glob
import json
import sys
import os
import re


DOCROOT = 'www'
PUBLIC_CACHE = 'public, max-age=2678400'
MANIFEST_FILE = f'{DOCROOT}/manifest.txt'


location = sys.argv[1]
static_json = sys.argv[2]

data = json.load(open(static_json))

def regexified(location):
    return ('^/' + re.escape(location) + '/teaser/(.*)').replace('//', '/')

# all files except .html should be cached
for pubcache in map(lambda x: x[len(DOCROOT):], glob.glob(f'{DOCROOT}/**')):
    if pubcache[-5:] == '.html':
        continue
    if pubcache not in data['headers']:
        data['headers'][pubcache] = dict()
    data['headers'][pubcache]['Cache-Control'] = PUBLIC_CACHE

if '/**' not in data['headers']:
    data['headers']['/**'] = dict()

if os.path.isfile(MANIFEST_FILE):
    with open(MANIFEST_FILE, 'rb') as f:
        # slice bytes from manifest and interpret as ascii-string
        # they follow this scheme: 'commit XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX …(+)'
        data['headers']['/**']['X-Carlconnectversion'] = f.read()[7:47].decode('ASCII')

data['routes']['/' + location + '/**'] = location + '/index.html'

json.dump(data, open(static_json, 'w'), indent=2)
