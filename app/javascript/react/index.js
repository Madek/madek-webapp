// collect top-level components needed for ujs and/or server-side render:

const requireBulk = require('bulk-require'); // require file/directory trees

module.exports = {

  // "UI library" (aka styleguide)
  // NOTE: 'requireBulk' is in the index file so that other components can use it
  UI: require('./ui-components/index.js'),

  // Decorators: components that directly receive (sub-)presenters
  // NOTE: only needed for remaining HAML views…
  Deco: requireBulk(__dirname, ['./decorators/*.{c,}js{x,}', './decorators/**/*.{c,}js{x,}']).decorators,

  // Views: Everything else that is rendered top-level (`react` helper)
  // NOTE: also because of HAML views there are sub-folders for "partials and actions".
  //       Will be structured more closely to the actual routes where they are used.
  Views: requireBulk(__dirname, ['./views/*.{c,}js{x,}', './views/**/*.{c,}js{x,}']).views,

  // App/Layout things that are only temporarly used from HAML:
  App: {
    UserMenu: require('../react/views/_layouts/UserMenu.jsx'),
    LoginMenu: require('../react/views/_layouts/LoginMenu.js').default,
    TestLoginForm: require('../react/views/_layouts/TestLoginForm.js').default
  }
};
