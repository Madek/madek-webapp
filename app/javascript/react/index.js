// collect top-level components needed for ujs and/or server-side render:

import { globToNested } from '../lib/glob-to-nested.js'
import UI from './ui-components/index.js'
import Views from './views/index.js'
import UserMenu from './views/_layouts/UserMenu.jsx'
import { default as LoginMenu } from './views/_layouts/LoginMenu.jsx'
import { default as TestLoginForm } from './views/_layouts/TestLoginForm.jsx'

// Decorators: auto-discover all files in decorators/ tree
// Strip './decorators/' prefix so result is: { BatchAddToSet: ..., resourcesbox: { ... } }
const decoratorModules = import.meta.glob(
  ['./decorators/*.{js,jsx}', './decorators/**/*.{js,jsx}'],
  { eager: true }
)
const Deco = globToNested(decoratorModules, './decorators/')

export default {
  UI,
  Deco,
  Views,
  // App/Layout things that are only temporarily used from HAML:
  App: {
    UserMenu,
    LoginMenu,
    TestLoginForm
  }
}
