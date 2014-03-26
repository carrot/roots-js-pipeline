Roots JS Pipeline
=================

[![npm](https://badge.fury.io/js/js-pipeline.png)](http://badge.fury.io/js/js-pipeline) [![tests](https://travis-ci.org/carrot/roots-js-pipeline.png?branch=master)](https://travis-ci.org/carrot/roots-js-pipeline) [![dependencies](https://david-dm.org/carrot/roots-js-pipeline.png?theme=shields.io)](https://david-dm.org/carrot/roots-js-pipeline)

Roots js pipeline is an asset pipeline for javascript files which optionally concatenates and/or minifies for production builds.

> **Note:** This project is in early development, and versioning is a little different. [Read this](http://markup.im/#q4_cRZ1Q) for more details.

### Installation

- make sure you are in your roots project directory
- `npm install js-pipeline --save`
- modify your `app.coffee` file to include the extension, as such

  ```coffee
  js_pipeline = require('js-pipeline')

  module.exports =
    extensions: [js_pipeline(files: "assets/js/**", out: 'js/build.js', minify: true)]
  ```

### Usage

So there are two ways you can use this plugin, which revolve around whether you are using the `files` key as seen above or the `main` key, which points to what we call a "manifest file". They both work the same way, allowing you to specify an array of requirements and either include them all or concat and minify into a single file. First, let's talk about the `files` key.

The example above shows a [minimatch](https://github.com/isaacs/minimatch) string (which could also be an array of minimatch strings) passed in as `files`. If you pass an array, the scripts will be loaded in that order. For any globstar matches that a minimatch string makes, the files will be included in an arbitrary order.

You can also use a manifest file to specify the load order. To do this, rather than the `files` property, add a `main` property which points to a yaml file that can load your deps for you. For example, for a folder structure like this:

```
js
˻ manifest.yml
˻ main.coffee
˻ vendor
  ˻ jquery
    ˻ jquery.min.js
    ˻ jquery.min.map
  ˻ jquery.plugin.min.js
```

...your manifest file might look like this:

```yml
- vendor/jquery/*
- vendor/jquery.plugin.min.js
- main.coffee
```

..and your roots config might look like this:

```coffee
js_pipeline = require('js-pipeline')

module.exports =
  extensions: [js_pipeline(main: "js/manifest.yml", out: 'js/build.js', minify: true)]
```

A couple things to note. First, the manifest file just looks like a bulleted list. This is the intent. Nice and clean.

Second, whatever directory the manifest file is in serves as the root from which it loads other scripts. The manifest file itself is automatically ignored from the compile process, and you can call it whatever you want. We just called it `manifest.yml` here because it seemed to make sense.

Finally, in this example, `vendor/jquery` is a minimatch string, not a filename. If you pass a globstar matching string, all the matching files will be loaded in an arbitrary order. If you need the scripts in a folder to come in a certain order, list them out individually. For example, although all the files inside `vendor` were loaded, we still listed them manually because `jquery` has to load before `jquery.plugin`, so an arbitrary order won't make the cut here.

Now, to actually inject the scripts, you will then have a function called `js` made available in _all your views_, which you can execute to output the tag or tags needed. If you specify an `out` path, all the matched files will all be concatenated and that one file will be inserted into a view wherever the `js` function is called, and if not, it will individually compile each file and output tags linking to each one.

For example, in a jade view:

```jade
!= js()
//- outputs "<script src='/js/build.js'></script>"
//- or if no output path, script tags for each js file matched
```

You should choose to load your files either through `main` or `files`. If you use both, `main` will win the battle.

### Options

##### files
String or array of strings ([minimatch](https://github.com/isaacs/minimatch) supported) pointing to one or more file paths to be built.

##### main
A path, relative to the roots project's root, to a _manifest file_ (explained above), which contains a list of strings ([minimatch](https://github.com/isaacs/minimatch) supported) pointing to one more more files to be built.

##### out
If provided, all input files will be concatenated to this single path. Default is `false`

##### minify
Minfifies the output. Default is `false`.

##### opts
Options to be passed into the minifier. Only does anything useful when minify is true. Possible options can be seen [here](https://github.com/mishoo/UglifyJS2#the-simple-way).

##### hash
Boolean, and only works when `out` is also defined. Hashes the file contents and appends to the filename. This is typically used for cache-busting. Always puts the hash before the final extension, for example `file.x.y.HASH.js`. The hash is a lengthy string of random numbers and letters, and the name change is automatically reflected by the `js` function in your views. Default is `false`.

### License & Contributing

- Details on the license [can be found here](LICENSE.md)
- Details on running tests and contributing [can be found here](contributing.md)
