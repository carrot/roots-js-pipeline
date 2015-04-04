path      = require 'path'
fs        = require 'fs'
should    = require 'should'
Roots     = require 'roots'
_path     = path.join(__dirname, 'fixtures')
RootsUtil = require 'roots-util'
h = new RootsUtil.Helpers(base: _path)

# setup, teardown, and utils

compile_fixture = (fixture_name, done) ->
  @public = path.join(fixture_name, 'public')
  h.project.compile(Roots, fixture_name).done(done)

before (done) ->
  h.project.install_dependencies('*', done)

after ->
  h.project.remove_folders('**/public')

# tests

describe 'development', ->

  before (done) -> compile_fixture.call(@, 'development', -> done())

  it 'js function should output a tag for each file', ->
    p = path.join(@public, 'index.html')
    h.file.contains(p, 'test.js').should.be.ok
    h.file.contains(p, 'wow.js').should.be.ok

  it 'files should have correct content', ->
    p1 = path.join(@public, 'js/test.js')
    p2 = path.join(@public, 'js/wow.js')
    h.file.exists(p1).should.be.ok
    h.file.contains(p1, "console.log('tests');").should.be.ok
    h.file.contains(p1, "@preserve").should.be.ok
    h.file.exists(p2).should.be.ok
    h.file.contains(p2, '9000 + 1;').should.be.ok

describe 'concat', ->

  before (done) -> compile_fixture.call(@, 'concat', -> done())

  it 'js function should output a tag for the build file', ->
    p = path.join(@public, 'index.html')
    h.file.contains(p, 'build.js').should.be.ok

  it 'build file should have correct content', ->
    p = path.join(@public, 'js/build.js')
    h.file.exists(p).should.be.ok
    h.file.contains(p, "console.log('tests');").should.be.ok
    h.file.contains(p, '9000 + 1;').should.be.ok

describe 'concat-minify', ->

  before (done) -> compile_fixture.call(@, 'concat-minify', -> done())

  it 'js function should output a tag for the build file', ->
    p = path.join(@public, 'index.html')
    h.file.contains(p, 'build.min.js').should.be.ok

  it 'build file should have correct content', ->
    p = path.join(@public, 'js/build.min.js')
    h.file.exists(p).should.be.ok
    h.file.contains(p, 'console.log(9001)').should.be.ok
    h.file.contains(p, 'console.log(100)').should.be.ok

describe 'hash', ->

  before (done) -> compile_fixture.call(@, 'hash', -> done())

  it 'js function should output a tag for the hashed build file', ->
    p = path.join(@public, 'index.html')
    filename = fs.readdirSync(path.join(_path, @public, 'js'))[0]

    h.file.contains(p, filename).should.be.ok

describe 'manifest', ->

  before (done) -> compile_fixture.call(@, 'manifest', -> done())

  it 'js function should output a tag for each file', ->
    p = path.join(@public, 'index.html')
    h.file.contains(p, 'j-snizzle.js').should.be.ok
    h.file.contains(p, 'p-nizzle.js').should.be.ok
    h.file.contains(p, 'test.js').should.be.ok
    h.file.contains(p, 'wow.js').should.be.ok
    h.file.contains(p, 'doge-wow.shh.amaze.js').should.be.ok

  it 'files should have correct content', ->
    p1 = path.join(@public, 'js/test.js')
    p2 = path.join(@public, 'js/wow.js')
    p3 = path.join(@public, 'js/jquizzy/j-snizzle.js')
    p4 = path.join(@public, 'js/jquizzy/p-nizzle.js')
    h.file.exists(p1).should.be.ok
    h.file.contains(p1, "console.log('tests');").should.be.ok
    h.file.exists(p2).should.be.ok
    h.file.contains(p2, '9000 + 1;').should.be.ok
    h.file.exists(p3).should.be.ok
    h.file.contains(p3, "function jquizzle(izzle){").should.be.ok
    h.file.exists(p4).should.be.ok
    h.file.contains(p4, "$ = 'wow'").should.be.ok

  it 'manifest file should be ignored from output', ->
    h.file.doesnt_exist(path.join(@public, 'js/manifest.yml')).should.be.ok

describe 'concat-manifest', ->

  before (done) -> compile_fixture.call(@, 'concat-manifest', -> done())

  it 'js function should output a tag for the build file', ->
    p = path.join(@public, 'index.html')
    h.file.contains(p, 'build.js').should.be.ok

  it 'build file should have correct content', ->
    p = path.join(@public, 'js/build.js')
    h.file.exists(p).should.be.ok
    h.file.contains(p, "function jquizzle(izzle){\n  return 'pizzle'\n}\n$ = 'wow'\n(.should.be.okfunction() {\n  console.log('tests');\n\n}).call(this);\n(function() {\n  9000 + 1;\n\n}).call(this);")

describe 'path-prefix', ->

  before (done) -> compile_fixture.call(@, 'path-prefix', -> done())

  it 'should prefix the path correctly', ->
    p = path.join(@public, 'index.html')
    h.file.contains(p, '../js/test.js').should.be.ok
    h.file.contains(p, '../js/wow.js').should.be.ok
