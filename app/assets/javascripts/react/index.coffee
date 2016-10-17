# collect top-level components needed for ujs and/or server-side render:
React = require('react')
f = require('active-lodash')
requireBulk = require('bulk-require') # require file/directory trees

react =
  # "UI library" (aka styleguide)
  # NOTE: 'requireBulk' is in the index file so that other components can use it
  UI: require('./ui-components/index.coffee')

  # Decorators: components that directly receive (sub-)presenters
  # NOTE: only needed for remaining HAML views…
  Deco: requireBulk(__dirname, ['./decorators/*.{c,}js{x,}', './decorators/**/*.{c,}js{x,}']).decorators

  # Views: Everything else that is rendered top-level (`react` helper)
  # NOTE: also because of HAML views there are sub-folders for "partials and actions".
  #       Will be structured more closely to the actual routes where they are used.
  Views: requireBulk(__dirname, ['./views/*.{c,}js{x,}', './views/**/*.{c,}js{x,}']).views

  # App/Layout things that are only temporarly used from HAML:
  App:
    AppHeader: require('../react/views/App/AppHeader.js').default
    AppFooter: require('../react/views/App/AppFooter.js').default


  # extra stuff
  AsyncDashboardSection: require('./lib/AsyncDashboardSection.cjsx')

# NEW ROOT (everything will move here). (old UJS just works)
# this index will be removed and the Root directly inmported into `./react-server-side.js`
react.Root = require('./Root.js').default

module.exports = react
