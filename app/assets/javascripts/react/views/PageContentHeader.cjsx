React = require('react')
ReactDOM = require('react-dom')

module.exports = React.createClass
  displayName: 'PageContentHeader'

  render: ({icon} = @props) ->
    <div className="ui-body-title">
      <div className="ui-body-title-label">
        <h1 className="title-xl">
          <i className={'icon-' + icon}/> {@props.title}
        </h1>
      </div>
      <div className="ui-body-title-actions">
        {@props.children}
      </div>
    </div>
