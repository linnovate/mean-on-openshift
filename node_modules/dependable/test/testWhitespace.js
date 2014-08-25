coffee = require('coffee-script');
container = require('../index').container();
assert = require('assert');

describe('resolve', function () {
  container.register('foo', {});
  container.register('bar', 'hurp');
  container.register('baz', 1);

  it('correctly parses functions with newlines in the argument lists', function (done) {
    container.resolve(function(foo, bar,
                            baz) {
      done();
    });
  });
});
