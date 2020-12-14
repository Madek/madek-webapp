import React, { Component } from 'react'
import f from 'lodash'
import t from '../../../lib/i18n-translate'
import UI from '../../ui-components/index.coffee'
import MediaResourcesLine from './MediaResourcesLine.jsx'

class MediaEntrySiblings extends Component {
  constructor(props) {
    super(props)
    this.state = {
      resourcesByCollection: []
    }
  }

  componentDidMount() {
    this._isMounted = true
    this.fetchSiblings()
  }

  componentWillUnmount() {
    this._isMounted = false
  }

  fetchSiblings() {
    this.setState({ resourcesByCollection: this.props.siblings })
  }

  render() {
    const { resourcesByCollection } = this.state
    const { authToken } = this.props

    return (
      <div className='ui-container midtone bordered rounded mbh pam'>
        <h3 className='title-l pbm'>
          Other media entries in the same set
        </h3>

        {f.map(resourcesByCollection, (obj) =>
          <div key={obj.collection.uuid}>
            <h4 className='title-m pbs'>
              Parent set: {obj.collection.title} {' '}
              <a href={obj.collection.url} style={{textDecoration: 'none'}}>
                <UI.Icon i='link' />
              </a>
            </h4>

            <MediaResourcesLine
              resources={obj.media_entries}
            />
          </div>
        )}
      </div>
    )
  }
}

export default MediaEntrySiblings
