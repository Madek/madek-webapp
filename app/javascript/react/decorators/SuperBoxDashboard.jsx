import React from 'react'
import ReactDOM from 'react-dom'
import l from 'lodash'
import ResourceThumbnail from './ResourceThumbnail.jsx'

class SuperBoxDashboard extends React.Component {

  constructor(props) {
    super(props)
  }

  renderResource(config) {
    return (
      <ResourceThumbnail elm='div'
        style={null}
        get={config.resource}
        isClient={true} fetchRelations={true}
        isSelected={false} onSelect={null} 
        authToken={config.authToken} key={'resource_' + config.resource.uuid}
        pinThumb={false}
        listThumb={false}
      />
    )
  }

  renderResources(config) {
    return l.map(
      config.resources,
      (r) => {
        return this.renderResource({resource: r, authToken: config.authToken})
      }
    )
  }

  render() {
    var resources = this.props.resources
    var authToken = this.props.authToken

    return (
      <div className='ui-resources-holder'>
        <div className='ui-container table auto'>
          <div className='ui-container table-cell table-substance'>
            <ul className='grid active ui-resources'>
              <li className='ui-resources-page'>
                <ul className='ui-resources-page-items'>
                  {this.renderResources({resources: resources, authToken: authToken})}
                </ul>
              </li>
            </ul>
          </div>
        </div>
      </div>
    )
  }
}

module.exports = SuperBoxDashboard
