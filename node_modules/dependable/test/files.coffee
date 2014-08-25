path      = require 'path'
assert    = require 'assert'
container = require('../index').container

describe 'File Names', ->
  it 'should load files with dashes in a sane way', (done) ->
    deps = container()

    dashedFileUser = (roflCoptor) ->
      assert.ok roflCoptor
      done()

    deps.load path.join(__dirname, 'test-files')
    deps.register 'dashedFileUser', dashedFileUser
    deps.get 'dashedFileUser'
