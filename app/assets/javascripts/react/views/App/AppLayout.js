// NOTE: DONT TOUCH THIS YET - shared implementation with haml

import React from 'react'

import AppHeader from './AppHeader'
import AppFooter from './AppFooter'

// AppLayout.propTypes = {
//   footer: PropTypes.shape({
//     text: PropTypes.string.isRequired,
//     menu: PropTypes.arrayOf(PropTypes.string.isRequired),
//     copy: PropTypes.shape({
//       href: PropTypes.string,
//       content: PropTypes.string,
//       name: PropTypes.string,
//       description: PropTypes.string,
//       info_url: PropTypes.string
//     }),
//     version: PropTypes.shape({
//       title: PropTypes.string,
//       version: PropTypes.string,
//       name: PropTypes.string,
//       description: PropTypes.string,
//       info_url: PropTypes.string
//     })
//   })
// }

class AppLayout extends React.Component {
  render ({app, modal, children} = this.props) {
    // build header/footer config:
    const headerProps = {
      ...app.header,
      brand: {
        name: app.config.site_title,
        logo: app.config.brand_logo_url,
        provider: app.config.brand_text,
        href: app.config.root_path
      },
      userMenu: app.user_menu,
      loginLink: app.login_link,
      authToken: app.auth_token
    }

    const footerProps = {
      menu: app.sitemap,
      provider: app.config.brand_text,
      version: app.version
    }

    return <div>

      {/* TODO: {modal} */}

      <AppWrapper>

        <AppHeader {...headerProps}/>

        {/* TODO: {!modal && alerts()} */}

        <AppBody>
          {children}
        </AppBody>

      </AppWrapper>
      <AppFooter {...footerProps}/>

    </div>
  }
}

export default AppLayout

// partials:

const AppWrapper = ({children}) => <div id='app' className='app'>
  {children}
  <div className='app-footer-push'/>
</div>

const AppBody = ({children}) => <div className='app-body'>{children}</div>
