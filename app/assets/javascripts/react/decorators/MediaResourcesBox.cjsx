React = require('react')
f = require('active-lodash')
ampersandReactMixin = require('ampersand-react-mixin')

ResourceThumbnail = require('./ResourceThumbnail.cjsx')

module.exports = React.createClass
  displayName: 'MediaResourcesBox'
  mixins: [ampersandReactMixin]

  render: ({list} = @props)->
    <ul className='grid ui-resources'>
      {list.map (item)->
        <li className='ui-resource' key={item.uuid or item.cid}>
          <div className='ui-resource-body'>
            <ResourceThumbnail resource={item}/>
          </div>
        </li>
      }
    </ul>
