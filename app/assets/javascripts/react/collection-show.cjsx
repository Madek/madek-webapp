React = require('react')
ReactDOM = require('react-dom')
f = require('active-lodash')
t = require('../lib/string-translation.js')('de')
RailsForm = require('./lib/forms/rails-form.cjsx')
MediaResourcesBox = require('./decorators/MediaResourcesBox.cjsx')
RightsManagement = require('./rights-management.cjsx')
CollectionDetail = require('./views/collection-detail.cjsx')
CollectionRelations = require('./views/collection-relations.cjsx')
CollectionMetadata = require('./views/collection-metadata.cjsx')

classnames = require('classnames')

module.exports = React.createClass
  displayName: 'Base'

  render: ({authToken, get, activeTab} = @props) ->
    <div className="app-body-ui-container">
      <div className="ui-body-title">
        <div className="ui-body-title-label">
          <h1 className="title-xl">
            <i className="icon-set"/> {get.title}
          </h1>
        </div>
        <div className="ui-body-title-actions">
          {f.map get.buttons, (button) ->
            <ResourceButton key={button.action}
              icon={button.icon} title={button.title} name={button.action}
              href={button.action} method={button.method} authToken={authToken}/>
          }
        </div>
      </div>

      <ul className="ui-tabs large">
        {f.map get.tabs, (tab, index) ->
          <Tab get={get} key={tab.href} iconType={tab.icon_type} href={tab.href}
            label={tab.label} active={index == activeTab} />
        }
      </ul>

      {if activeTab == 0
        <CollectionDetail get={get} authToken={authToken} />
      }
      {if activeTab == 1
        <CollectionRelations get={get} authToken={authToken} />
      }
      {if activeTab == 2
        <CollectionMetadata get={get} authToken={authToken} />
      }
      {if activeTab == 3
        <div className="bright pal rounded-bottom rounded-top-right ui-container">
          <RightsManagement get={get.permissions} />
        </div>
      }
    </div>

Tab = React.createClass
  displayName: 'Tab'
  render: ({get, label, href, iconType, active} = @props) ->
    classes = classnames({ active: active}, 'ui-tabs-item')
    icon = if iconType == 'privacy_status_icon'
      if get.privacy_status
        icon_map = {
          public: 'open',
          shared: 'group',
          private: 'private'
        }
        <i className={'icon-privacy-' + icon_map[get.privacy_status]}/>

    <li className={classes}>
      <a href={href}>
        {if icon
          <span>{icon} {label}</span>
        else
          label
        }
      </a>
    </li>

ResourceButton = React.createClass
  displayName: 'ResourceButton'
  render: ({authToken, href, method, icon, title, name} = @props) ->
    method = 'post' if not method
    icon = 'icon-' + icon
    <RailsForm className='button_to' name='' method={method} action={href} authToken={authToken}>
      <button className="button" type="submit" title={title}>
        <i className={icon}></i>
      </button>
    </RailsForm>
