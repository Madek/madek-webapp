/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS207: Consider shorter variations of null checks
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
import React from 'react'
import createReactClass from 'create-react-class'
import t from '../../../lib/i18n-translate.js'
import f from 'lodash'
import cx from 'classnames'
import UI from '../../ui-components/index.js'
import Preloader from '../../ui-components/Preloader.jsx'
import loadXhr from '../../../lib/load-xhr.js'
import libUrl from 'url'
import setUrlParams from '../../../lib/set-params-for-url.js'

module.exports = createReactClass({
  displayName: 'ExploreCatalogCategoryPage',

  getInitialState() {
    return {
      metaKeyValuePages: [this._initialMetaKeyValuePage()],
      loading: false
    }
  },

  _initialMetaKeyValuePage() {
    return f.cloneDeep(this.props.get.meta_key_values)
  },

  _lastPage() {
    return f.last(this.state.metaKeyValuePages)
  },

  _tryLoadNext() {
    if (this.state.loading) {
      return
    }

    if (!this._isBottom()) {
      return
    }

    if (!this._lastPage().has_more) {
      return
    }

    return this.setState({ loading: true }, () => {
      return this._ajaxRequest()
    })
  },

  _ajaxRequest() {
    const lastPage = this._lastPage()

    const url = setUrlParams(libUrl.parse(this.props.for_url).pathname, {
      page_size: 3,
      start_index: lastPage.start_index + lastPage.page_size
    })

    return (this.xhrRef = loadXhr(
      {
        method: 'GET',
        url
      },
      (result, data) => {
        if (result === 'success') {
          this.setState({
            metaKeyValuePages: f.concat(this.state.metaKeyValuePages, data.meta_key_values)
          })
        }

        return this.setState({ loading: false }, () => {
          return this._tryLoadNext()
        })
      }
    ))
  },

  _getDocHeight() {
    const D = document
    return Math.max(
      D.body.scrollHeight,
      D.documentElement.scrollHeight,
      D.body.offsetHeight,
      D.documentElement.offsetHeight,
      D.body.clientHeight,
      D.documentElement.clientHeight
    )
  },

  _scrollTop() {
    return Math.max(document.body.scrollTop, document.documentElement.scrollTop)
  },

  _isBottom() {
    return (
      this._scrollTop() + window.innerHeight > this._getDocHeight() * 0.3 ||
      window.innerHeight > this._getDocHeight() * 0.3
    )
  }, // || @_getDocHeight() < 3000

  componentDidMount() {
    this._tryLoadNext()
    return window.addEventListener('scroll', this._onScroll)
  },

  componentWillUnmount() {
    // Assumption:
    // If your XHR is pending, and you go to the next page and use the browser back button, then
    // you most likely do not enter the XHR callback, which in this component means,
    // that the next page is not loaded. Thats why we explicitly cancel it.
    if (this.xhrRef) {
      this.xhrRef.cancel()
    }
    return window.removeEventListener('scroll', this._onScroll)
  },

  _onScroll() {
    return this._tryLoadNext()
  },

  render(param) {
    if (param == null) {
      param = this.props
    }
    const { get } = param
    return (
      <div>
        <div className="app-body-ui-container pts context-home">
          <h1 className="title-xl mtl mbm">{get.catalog_title + ' / ' + get.title}</h1>
          <div className="ui-resources-holder pal">
            {f.compact(
              f.map(
                f.flatten(f.map(this.state.metaKeyValuePages, page => page.values)),
                keyword => {
                  if (f.isEmpty(keyword.media_entries)) {
                    return null
                  }

                  return (
                    <div key={keyword.uuid}>
                      <div className="ui-resources-header">
                        <h2 className="title-l ui-resource-title" style={{ marginBottom: '15px' }}>
                          {keyword.label}
                          <a className="strong" href={keyword.url}>
                            {t('explore_show_more')}
                          </a>
                        </h2>
                      </div>
                      <MediaResourcesLine keyword={keyword} />
                    </div>
                  )
                }
              )
            )}
            {this._lastPage().has_more ? <Preloader /> : undefined}
          </div>
        </div>
      </div>
    )
  }
})

var MediaResourcesLine = function (param) {
  const { keyword } = param
  const resources = f.map(keyword.media_entries, 'sparse_props')

  return (
    <div className="ui-container rounded-right pbm" key={keyword.uuid}>
      <div className="ui-container rounded-right">
        <div className="ui-featured-entries small active">
          <ul className="ui-featured-entries-list">
            {f.map(resources, ({ uuid, url, browse_url, image_url, media_type }) => (
              <li key={keyword.uuid + '_' + uuid} className="ui-featured-entries-item">
                <a
                  className={cx('ui-featured-entry', {
                    [`is-${media_type}`]: !!media_type
                  })}
                  href={url}>
                  <img src={image_url} />
                </a>
                <ul className="ui-featured-entry-actions">
                  <li className="ui-featured-entry-action">
                    <a
                      className="block"
                      href={browse_url}
                      title={t('browse_entries_browse_link_title')}>
                      <UI.Icon i="eye" />
                    </a>
                  </li>
                </ul>
              </li>
            ))}
          </ul>
        </div>
      </div>
      <hr className="separator" />
    </div>
  )
}
