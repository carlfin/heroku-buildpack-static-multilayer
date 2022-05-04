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

This buildpack relies on information from `app_structure.json` file like:

```json
{
  "top": "simple-sso"
  "nested": {
    "3so-advisor": "advisor",
    "investor": "investor",
    "admin": "admin"
  },
  "integration": true
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
