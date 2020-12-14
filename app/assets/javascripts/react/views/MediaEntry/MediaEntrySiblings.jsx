import React, { Component } from 'react'
import _ from 'lodash'
import t from '../../../lib/i18n-translate'
import { Icon } from '../../ui-components/index.coffee'
import appRequest from '../../../lib/app-request.coffee'
import MediaResourcesLine from './MediaResourcesLine.jsx'
import Preloader from '../../ui-components/Preloader.cjsx'

class MediaEntrySiblings extends Component {
  constructor(props) {
    super(props)
    this.state = {
      parentCollections: props.parentCollections || [],
      resourcesByCollection: [],
      isFetching: false,
      fetched: false
    }
  }

  componentDidMount() {
    this._isMounted = true
    this.fetchSiblings()
  }

  componentWillUnmount() {
    this._isMounted = false
  }

  prepareResources(data) {
    return _.filter(data, ({ media_entries }) => !_.isEmpty(media_entries))
  }

  fetchSiblings() {
    this.setState({ isFetching: true })
    this._fetching = appRequest(
      { url: this.props.get.siblings_url, sparse: { siblings: {} } },
      (err, res, data) => {
        if (!this._isMounted) return
        if (err && !data) {
          console.error('Error while fetching sibling entries data!\n\n', err)
          this.setState({ resourcesByCollection: false, isFetching: false })
        } else {
          this.setState({
            resourcesByCollection: this.prepareResources(data.siblings),
            isFetching: false,
            fetched: true
          })
        }
    })
  }

  render() {
    const { resourcesByCollection, isFetching, fetched } = this.state

    return (
      <div className='ui-container midtone bordered rounded mbh pam'>
        <h3 className='title-l pbm'>
          Other media entries in the same set
        </h3>

        {isFetching && <Preloader />}
        {fetched && _.isEmpty(resourcesByCollection) ? (
          <div className='by-center'>{t('no_content_fallback')}</div>
        ) : (
          _.map(resourcesByCollection, ({ collection, media_entries }) =>
            <div key={collection.uuid}>
              <h4 className='title-s pbs'>
                Parent set: {collection.title} {' '}
                <a href={collection.url} style={{textDecoration: 'none'}}>
                  <Icon i='link' />
                </a>
              </h4>

              <MediaResourcesLine
                resources={media_entries}
              />
            </div>
          )
        )}
      </div>
    )
  }
}

export default MediaEntrySiblings
