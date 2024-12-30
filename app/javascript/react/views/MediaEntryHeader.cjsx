React = require('react')
ReactDOM = require('react-dom')
HeaderButton = require('./HeaderButton.cjsx')
PageContentHeader = require('./PageContentHeader.cjsx')
f = require('active-lodash')
SelectCollection = require('./Collection/SelectCollection.cjsx')
AsyncModal = require('./Collection/AsyncModal.cjsx')
Dropdown = require('../ui-components/Dropdown.cjsx')
Menu = Dropdown.Menu
MenuItem = Dropdown.MenuItem
Icon = require('../ui-components/Icon.cjsx')
Link = require('../ui-components/Link.cjsx')
t = require('../../lib/i18n-translate.js')


module.exports = React.createClass
  displayName: 'MediaEntryHeader'

  getInitialState: () -> {
    active: @props.isClient
  }

  _onClick: (asyncAction) ->
    if @props.onClick
      @props.onClick(asyncAction)

  render: ({authToken, get} = @props) ->
    # TODO: Outer div should be removed based on the styleguide.
    # This will be possible, as soon as the modal dialog can be added in
    # a higher tree level.

    icon = if get.type == 'Collection' then 'set' else 'media-entry'

    buttons = f.compact(
      f.map(get.button_actions, (button_id) ->
        f.find(get.buttons, {id: button_id})
      )
    )

    menuItems = f.compact(
      f.map(get.dropdown_actions, (button_id) ->
        f.find(get.buttons, {id: button_id})
      )
    )

    banner = if f.any(get.new_version_entries)
      <div className="ui-alert warning ui-container inverted paragraph-l mbm">
        {t('media_entry_notice_new_versions')}
        <ul>
        {f.map(get.new_version_entries, (i) =>
          me = i.entry
          desc = f.present(i.description) ? i.description + ', ' : ''
          <li>
            <Link href={me.url} mods="strong" style={{color: '#adc671', textDecoration: 'underline'}}>
              {me.title}
            </Link>{' '}
            <em style={{fontStyle: 'italic'}}>({desc}{me.date})</em>
          </li>
        )}
        </ul>
      </div>

    <PageContentHeader
      icon={icon}
      title={get.title}
      workflow={get.workflow}
      banner={banner}
      sectionLabels={get.section_labels}
    >
      {
        f.map(
          buttons,
          (button) =>
            if button.async_action
              onClick = (event) => @_onClick(button.async_action)
            <HeaderButton key={button.id}
              onClick={onClick}
              icon={button.icon} fa={button.fa} title={button.title} name={button.action}
              href={button.action} method={button.method} authToken={authToken}/>
        )
      }
      {
        if !f.isEmpty(menuItems)
          <Dropdown mods='stick-right'
            toggle={t('resource_action_more_actions')} toggleProps={{className: 'button'}}>
            <Menu className='ui-drop-menu'>
              {
                f.map(
                  menuItems,
                  (button) =>
                    if button.async_action
                      onClick = (event) => @_onClick(button.async_action)
                    else if button.method == 'get'
                      href = button.action
                    else
                      throw new Error('In dropdown, a button must be either async or method "get", '
                        + 'but the dropdown does not support a form with "put/patch".')

                    <MenuItem key={button.id} onClick={onClick} href={href}
                      onMouseEnter={null} onMouseLeave={null} target={button.target}>
                      <Icon i={button.icon} mods='ui-drop-icon'
                        style={{position: 'static', display: 'inline-block', minWidth: '20px', marginLeft: '5px'}} />
                      <span style={{display: 'inline', marginLeft: '5px'}}>
                        {button.title}
                      </span>
                    </MenuItem>
                )
              }
            </Menu>
          </Dropdown>
      }
    </PageContentHeader>
