// collect top-level components needed for ujs and/or server-side render:

// Use webpack's require.context instead of bulk-require
const decoratorsContext = require.context('./decorators', true, /\.(jsx?|coffee)$/)
const decorators = {}

decoratorsContext.keys().forEach(key => {
  const parts = key
    .replace(/^\.\//, '')
    .replace(/\.(jsx?|coffee)$/, '')
    .split('/')
  const fileName = parts[parts.length - 1]
  decorators[fileName] = decoratorsContext(key).default || decoratorsContext(key)
})

module.exports = {
  // "UI library" (aka styleguide)
  UI: require('./ui-components/index.js'),

  // Decorators: components that directly receive (sub-)presenters
  // NOTE: only needed for remaining HAML views…
  Deco: decorators,

  // Views: Everything else that is rendered top-level (`react` helper)
  // NOTE: also because of HAML views there are sub-folders for "partials and actions".
  //       Will be structured more closely to the actual routes where they are used.
  Views: require('./views/index.js').views,

  // App/Layout things that are only temporarly used from HAML:
  App: {
    UserMenu: require('../react/views/_layouts/UserMenu.jsx'),
    LoginMenu: require('../react/views/_layouts/LoginMenu.js').default,
    TestLoginForm: require('../react/views/_layouts/TestLoginForm.js').default
  }
}
