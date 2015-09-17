fs        = require 'fs'
path      = require 'path'
_         = require 'lodash'
minimatch = require 'minimatch'
UglifyJS  = require 'uglify-js'
crypto    = require 'crypto'
RootsUtil = require 'roots-util'
yaml      = require 'js-yaml'

module.exports = (opts) ->

  opts = _.defaults opts,
    files: ['assets/js/**']
    manifest: false
    out: false
    minify: false
    hash: false
    opts: {}

  opts.opts.fromString = true
  opts.opts.comments = true
  opts.files = Array.prototype.concat(opts.files)

  class JSPipeline

    ###*
     * Sets up the custom category and view function.
     * The view function grabs either the single output path or collects
     * all non-ignored output paths for the input files and returns them
     * as html link tags.
     *
     * @param  {Function} @roots - Roots class instance
    ###

    constructor: (@roots) ->
      @category = 'js-pipeline'
      @file_map = {}
      @util = new RootsUtil(@roots)

      if opts.manifest
        @roots.config.ignores.push(opts.manifest)
        @manifest = load_manifest_file.call(@, opts.manifest)

      @files = @manifest or opts.files

      @roots.config.locals ?= {}
      @roots.config.locals.js = (prefix = '') =>
        paths = []

        if opts.out
          paths.push("#{prefix}#{opts.out}")
        else
          for matcher in @files
            paths = paths.concat(get_output_paths.call(@, matcher, prefix))

        paths.map((p) -> "<script src='#{p}'></script>").join("\n")

    ###*
     * Minimatch runs against each path, quick and easy.
    ###

    fs: ->
      extract: true
      detect: (f) => _.any(@files, minimatch.bind(@, f.relative))

    ###*
     * After compile, if concat is happening, grab the contents and save them
     * away, then prevent write.
    ###

    compile_hooks: ->
      write: -> !opts.out
      after_file: (ctx) =>
        if opts.out then @file_map[ctx.file.relative] = ctx.content

    ###*
     * Write the output file if necessary.
    ###

    category_hooks: ->
      after: (ctx) =>
        if not opts.out then return

        all_contents = ''
        for matcher in @files
          for file, content of @file_map when minimatch(file, matcher)
            all_contents += content + "\n"

        if opts.minify
          all_contents = UglifyJS.minify(all_contents, opts.opts).code

        if opts.hash
          hash = crypto.createHash('md5').update(all_contents, 'utf8')
          res = opts.out.split('.')
          res.splice(-1, 0, hash.digest('hex'))
          opts.out = res.join('.')

        @util.write(opts.out, all_contents)

    load_manifest_file = (f) ->
      res = yaml.safeLoad(fs.readFileSync(path.join(@roots.root, f), 'utf8'))
      res.map((m) -> path.join(path.dirname(f), m))

    get_output_paths = (files, prefix) ->
      @util.files(files).map (f) =>
        filePath = @util.output_path(f.relative).relative
        path.join(prefix, filePath.replace(path.extname(filePath), '.js'))
