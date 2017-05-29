React = require('react')
ReactDOM = require('react-dom')
HeaderButton = require('./HeaderButton.cjsx')
PageContentHeader = require('./PageContentHeader.cjsx')
f = require('active-lodash')
SelectCollection = require('./Collection/SelectCollection.cjsx')
AsyncModal = require('./Collection/AsyncModal.cjsx')

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

    <PageContentHeader icon={icon} title={get.title}>
      {f.map get.buttons, (button) =>
        if button.async_action
          onClick = (event) => @_onClick(button.async_action)
        <HeaderButton key={button.action}
          onClick={onClick}
          icon={button.icon} fa={button.fa} title={button.title} name={button.action}
          href={button.action} method={button.method} authToken={authToken}/>
      }
    </PageContentHeader>
