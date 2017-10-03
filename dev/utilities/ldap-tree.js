var f = require('active-lodash')

module.exports = function ldapTree (data) {
  var res = data
    .filter((item) => blackList(item.institutional_name))
    .filter((item) => !f.present(item))
    .reduce((prev, item, index) => {
      function buildTree (itm) {
        var str = itm.institutional_name.split('.')[0] // minus '.foo'
          .split('_')
        return treeFromList(str, itm)
      }

      var tree

      // prepare tree for the first item
      if (index === 1) {
        tree = buildTree(prev)
      } else {
        tree = prev
      }

      // make branch for current item
      var branch = buildTree(item)

      // merge branch into tree
      return f.merge(tree, branch)
    })

  return res
}

// TODO: port code from frontend to module and require here (and there)
function blackList (string) {
  var ldap_name = string
  var shouldKeep = false

  var ldapFilterConfig = {
    blackList: [/^Verteilerliste.*/, /^mittelbau.*/, /^personal.*/, /^studierende.*/, /^dozierende.*/],
    whiteList: [/.*\.alle$/]
  }

  ldapFilterConfig.whiteList.forEach(function (white) {
    if (ldap_name.match(white)) {
      shouldKeep = true
      ldapFilterConfig.blackList.forEach(function (black) {
        if (ldap_name.match(black)) {
          shouldKeep = false
        }
      })
    }
  })

  return shouldKeep
}

// recurse a `list` from the end and build a single-branch tree
// ex.: list='FOO_BAR_BAZ', leaf='foo' => {FOO:BAR:BAZ:'foo'}
function treeFromList (list, leaf) {
  // leaf= value of most inner key, default is empty object
  var result = leaf || {}

  if (list.length > 0) {
    var o = {}
    var key = list.pop(1)
    o[key] = result
    return treeFromList(list, o)
  } else {
    return result
  }
}
