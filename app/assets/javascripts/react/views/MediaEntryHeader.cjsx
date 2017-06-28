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

module.exports = React.createClass
  displayName: 'MediaEntryHeader'

  getInitialState: () -> {
    active: @props.isClient
  }

  _onClick: (asyncAction) ->
    debugger
    if @props.onClick
      @props.onClick(asyncAction)

  render: ({authToken, get} = @props) ->
    # TODO: Outer div should be removed based on the styleguide.
    # This will be possible, as soon as the modal dialog can be added in
    # a higher tree level.

    icon = if get.type == 'Collection' then 'set' else 'media-entry'

    <PageContentHeader icon={icon} title={get.title}>
      {
        f.map(
          get.button_actions,
          (button_id) =>
            button = f.find(get.buttons, { id: button_id })
            if button
              if button.async_action
                onClick = (event) => @_onClick(button.async_action)
              <HeaderButton key={button_id}
                onClick={onClick}
                icon={button.icon} fa={button.fa} title={button.title} name={button.action}
                href={button.action} method={button.method} authToken={authToken}/>

        )
      }
      {
        if !f.isEmpty(get.dropdown_actions)
          <Dropdown mods='stick-right'
            toggle={'Aktionen'} toggleProps={{className: 'button'}}>
            <Menu className='ui-drop-menu'>
              {
                f.map(
                  get.dropdown_actions,
                  (button_id) =>
                    button = f.find(get.buttons, { id: button_id })
                    if button
                      if button.async_action
                        onClick = (event) => @_onClick(button.async_action)
                      else if button.method == 'get'
                        href = button.action
                      else
                        throw new Error('In dropdown, a button must be either async or method "get", '
                          + 'but the dropdown does not support a form with "put/patch".')

                      <MenuItem key={button_id} onClick={onClick} href={href}
                        onMouseEnter={null} onMouseLeave={null}>
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
