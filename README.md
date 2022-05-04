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

## Resources

* [Heroku Buildpacks API Article](https://devcenter.heroku.com/articles/buildpack-api)
