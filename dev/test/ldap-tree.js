var assert= require('assert');
var ldapTree= require('../ldap-tree.js');
var fixtures= require('./fixtures/ldap-tree.test.json');

// test fixtures
fixtures.forEach(function (f) {
  var tree = ldapTree(f.data);
  assert.deepEqual(tree, f.result, 'Known output differs!');
});

// test/build madek data
var ldapData = require('../../db/ldap.json');
var tree = ldapTree(ldapData);

// // enable for output to stdout
console.log(JSON.stringify(tree, null, 2));

assert.ok(tree);
