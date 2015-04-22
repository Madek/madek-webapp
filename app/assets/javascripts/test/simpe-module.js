var test = require('tape');
var simpleModule = require('../test-module-js');

test('simple-module', function (t) {
  t.plan(2); // we expect 1 assertion

  // it is a function
  t.equal(typeof simpleModule, 'function')

  // it can be called with a string
  t.doesNotThrow(function () {
    simpleModule('hello')
  })
});
