React = require('react')
f = require('active-lodash')

module.exports = React.createClass
  displayName: 'ExploreMenu'
  render: ({} = @props)->
    index = 0
    <div className="app-body-sidebar bright ui-container table-cell bordered-right rounded-bottom-left table-side">
      <div className="ui-container rounded-left phm pvl">
        <ul className="ui-side-navigation">
          {f.map @props.children, (child, index) ->

            list = [ ]
            separator = <li key={'separator_' + index} className="separator mini"></li>
            list.push(separator) if index > 0
            list.push(child)
            list
          }
        </ul>
      </div>
    </div>
