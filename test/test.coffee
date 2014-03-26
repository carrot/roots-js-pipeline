path   = require 'path'
fs     = require 'fs'
should = require 'should'
glob   = require 'glob'
rimraf = require 'rimraf'
Roots  = require 'roots'
W      = require 'when'
nodefn = require 'when/node/function'
_path  = path.join(__dirname, 'fixtures')
run = require('child_process').exec

# setup, teardown, and utils

should.file_exist = (path) ->
  fs.existsSync(path).should.be.ok

should.have_content = (path) ->
  fs.readFileSync(path).length.should.be.above(1)

should.contain = (path, content) ->
  fs.readFileSync(path, 'utf8').indexOf(content).should.not.equal(-1)

compile_fixture = (fixture_name, done) ->
  @path = path.join(_path, fixture_name)
  @public = path.join(@path, 'public')
  project = new Roots(@path)
  project.compile().on('error', done).on('done', done)

before (done) ->
  tasks = []
  for d in glob.sync("#{_path}/*/package.json")
    p = path.dirname(d)
    if fs.existsSync(path.join(p, 'node_modules')) then continue
    console.log "installing deps for #{d.replace(_path,'').replace('/package.json','')}...".grey
    tasks.push nodefn.call(run, "cd #{p}; npm install")
  W.all(tasks).then(-> console.log(''); done())

after ->
  rimraf.sync(public_dir) for public_dir in glob.sync('test/fixtures/**/public')

# tests

describe 'development', ->

  before (done) -> compile_fixture.call(@, 'development', done)

  it 'js function should output a tag for each file', ->
    p = path.join(@public, 'index.html')
    should.contain(p, 'test.js')
    should.contain(p, 'wow.js')

  it 'files should have correct content', ->
    p1 = path.join(@public, 'js/test.js')
    p2 = path.join(@public, 'js/wow.js')
    should.file_exist(p1)
    should.contain(p1, "console.log('tests');")
    should.file_exist(p2)
    should.contain(p2, '9000 + 1;')

describe 'concat', ->

  before (done) -> compile_fixture.call(@, 'concat', done)

  it 'js function should output a tag for the build file', ->
    p = path.join(@public, 'index.html')
    should.contain(p, 'build.js')

  it 'build file should have correct content', ->
    p = path.join(@public, 'js/build.js')
    should.file_exist(p)
    should.contain(p, "console.log('tests');")
    should.contain(p, '9000 + 1;')

describe 'concat-minify', ->

  before (done) -> compile_fixture.call(@, 'concat-minify', done)

  it 'js function should output a tag for the build file', ->
    p = path.join(@public, 'index.html')
    should.contain(p, 'build.min.js')

  it 'build file should have correct content', ->
    p = path.join(@public, 'js/build.min.js')
    should.file_exist(p)
    should.contain(p, 'console.log(9001)')
    should.contain(p, 'console.log(100)')

describe 'hash', ->

  before (done) -> compile_fixture.call(@, 'hash', done)

  it 'js function should output a tag for the hashed build file', ->
    p = path.join(@public, 'index.html')
    filename = fs.readdirSync(path.join(@public, 'js'))[0]
    should.contain(p, filename)
