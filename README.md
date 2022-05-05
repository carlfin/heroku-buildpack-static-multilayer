# Buildpack Static Multilayer (for Heroku)

## Installation

Add the [Github URL](/carlfin/heroku-buildpack-static-multilayer) to the Buildpacks in heroku, it needs python buildpack run as a precondition,
also the static buildpack must run as postcondition.

A minimal stack of buildpacks from heroku would look like:
```
1. heroku/python
2. https://github.com/carlfin/heroku-buildpack-static-multilayer
3. https://github.com/carlfin/heroku-buildpack-static
```


## Detect

Checks for `app_structure.json` in deployed app folder.


## Configuration

Is loaded from codebase (config-file) and heroku config see following sections.

### Configuration File (codebase)

`app_structure.json` file like:

```json
{
  "toplevel": "simple-sso",
  "nested": {
    "3so-advisor": "advisor",
    "investor": "investor",
    "admin": "admin"
  },
  "integration": true
}
```


### Environment (heroku config)

* `GCS_KEY`
  * contains json google cloud service account json key (which can read under `STORAGE_URL`)
* `GCS_PROJECT`
  * google cloud project id which holds bucket from `STORAGE_URL`
* `STORAGE_URL`
  * for non-integration mode direct link to single branched download location inside `STORAGE_URL`
    e.g. `gs://my-cached-builds/my-app-name/single-branch`
  * for integration mode prefix to bucket is good enough e.g. `gs://my-cached-builds/`
* `STATIC_JSON`
  * template for heroku-buildpack-static `static.json` see example below.


Example for `STATIC_JSON`:

```json
{
  "root": "www/",
  "routes": {
  },
  "redirects": {
  },
  "headers": {
    "/**": {
      "Cache-Control": "private, no-cache, max-age=1"
    }
  },
  "https_only": true
}
```


### Nested structure

The `nested` has a mapping from download location as key and target folder as value.
That gives flexbility to switch to other apps under the same folder easily.


### Integration mode

will create server with nested structure:

* `<app_name>/<branch_name>`

Also the toplevel app will be run in integration/debug mode (from its staging branch codebase).


## Resources

* [Heroku Buildpacks API Article](https://devcenter.heroku.com/articles/buildpack-api)
* [Carlfin Heroku Buildpack Static](https://github.com/carlfin/heroku-buildpack-static)
