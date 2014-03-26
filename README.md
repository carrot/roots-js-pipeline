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

As can be seen above, the plugin takes a [minimatch](https://github.com/isaacs/minimatch) string (or array of minimatch strings) to build it's tree of processed files. You will then have the function `js` made available in all your views, when you can execute to output the tag or tags needed. If you specify an `out` path, all the matched files will all be concatenated and that one file will be inserted into a view wherever the `js` function is called, and if not, it will individually compile each file and output tags linking to each one.

For example, in a jade view:

```jade
!= js()
//- outputs "<script src='/js/build.js'></script>"
//- or if no output path, script tags for each js file matched by `files`
```

### Options

##### files
String or array of strings ([minimatch](https://github.com/isaacs/minimatch) supported) pointing to one or more file paths which will serve as the base.

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
