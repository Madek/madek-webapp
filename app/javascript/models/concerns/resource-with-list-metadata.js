/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
import setUrlParams from '../../lib/set-params-for-url.js'
import { parse as parseUrl, format as buildUrl } from 'url'
import { parse as parseQuery } from 'qs'

module.exports = {
  props: {
    list_meta_data: 'object'
  },

  loadListMetadata(callback) {
    const currentQuery = parseQuery(parseUrl(window.location.toString()).query)

    const parsedUrl = parseUrl(this.list_meta_data_url, true)
    delete parsedUrl.search

    const url = setUrlParams(buildUrl(parsedUrl), currentQuery)

    return this._runRequest(
      {
        url,
        json: true
      },
      (err, res, json) => {
        if (err) {
          return callback(err)
        } else {
          this.set('list_meta_data', json)
          return callback(err, res)
        }
      }
    )
  }
}
