// Root: server-side rendering by route, client-side remounting
// - Router matches URL, determines which *View* to render into `AppLayout`
// - injected props:
//   - All components: `props.app` (with "global config", mostly for layout)
//   - `AppLayout` receives determined View as `props.children`!
//   - View: `props.get` - the view-specifc data (the Presenter, like before)

import React from 'react'
import { Router, match, RouterContext, browserHistory, applyRouterMiddleware } from 'react-router'

// main app layout (i.e. everything in <body>),
// it's still wrapped in Rails `_base` layout for <head> etc)
import AppLayout from './views/App/AppLayout'

// all the Views:
import ExplorePage from './views/Explore/ExploreMainPage.cjsx'

// Routing Table (maps routes/paths to Views/ViewComponents)
const routes = [{
  path: '/',
  component: AppLayout,
  childRoutes: [
    { path: 'explore', component: ExplorePage },
    { path: 'explore/catalog', component: ExplorePage },
    { path: 'explore/catalog/:sectionId', component: ExplorePage },
    { path: 'explore/featured_set', component: ExplorePage },
    { path: 'explore/keywords', component: ExplorePage }
  ]
}]

// server-side: renders static HTML + injects the props as data
const ServerRoot = (props) => {
  if (!props.prerender) return null

  const location = props.app.url
  const viewProps = props.view.props
  const appProps = { app: props.app }

  // inject props given from backend:
  function createElement (Component, routerProps) {
    return <Component {...routerProps} {...appProps} {...viewProps} />
  }

  // NOTE: we can rely on this callback resolving synchronously
  //       see <https://github.com/ReactTraining/react-router/issues/1777#issuecomment-148415982>
  //       (otherwise it wouldn't work in `ExecJS`)
  let routerError, routerRedirectLocation, routerRouteProps, calledBack
  match({ routes, location }, (error, redirectLocation, renderProps) => {
    routerError = error
    routerRedirectLocation = redirectLocation
    routerRouteProps = renderProps
    calledBack = true
  })

  if (!calledBack) {
    throw new Error('`match` did not run!') // should never happen, see above
  }

  if (routerRedirectLocation) {
    // TODO: handle redirect?
    return <div>Redirect: <a href={routerRedirectLocation}>here</a></div>
  }

  if (routerError) {
    // TODO: handle error?
    return <div>Error: (routerError.stack || routerError.message)</div>
  }

  return <RouterContext {...routerRouteProps} createElement={createElement} />
}

// client-side: re-mount into the static HTML using props from injected data
const ClientRoot = (props) => {
  // inject props given from backend:
  const useExtraProps = {
    renderRouteComponent: (child) =>
      // pass through "view.props" and add "app" props (global settings)
      React.cloneElement(child, {...props.view.props, app: props.app})
  }
  return <Router
    history={browserHistory}
    routes={routes}
    render={applyRouterMiddleware(useExtraProps)}
  />
}

// export "isomorphic/universal" Root
// NOTE: this is the only place we have to check for client/server,
// the `ClientRoot` could simply always assume to be in the browser.
const Root = (props) => {
  const isClient = (window && !!window.document)
  return isClient ? ClientRoot(props) : ServerRoot(props)
}

export default Root
