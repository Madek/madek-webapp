import { present } from '../../lib/present';
import { get, includes, isFunction, last, set } from 'lodash-es';
import { parse as parseUrl, format as buildUrl } from 'url'

export default {
  props: {
    parent_collections: ['object'],
    sibling_collections: ['object']
  },
  // NOTE: Collections also have:
  // child_media_resources: ['object']

  // instance methods:
  fetchRelations(type, callback) {
    const validTypes = ['parent', 'sibling', 'child']
    if (!includes(validTypes, type)) {
      throw new Error('Invalid Relations type!')
    }
    // NOTE: format: ['subpath_of_action', 'jsonPath.inside.presenter']
    //       last part of jsonpath is the key inside here…
    const supportedRelations = {
      parent: ['relations', 'relations.parent_collections'],
      sibling: ['relations', 'relations.sibling_collections'],
      child: ['', 'child_media_resources']
    }
    const [subPath, jsonPath] = Array.from(supportedRelations[type])
    const modelAttr = last(jsonPath.split('.'))

    if (present(this.get(jsonPath))) {
      return
    } // only fetch if missing

    const sparseSpec = JSON.stringify(set({}, jsonPath, {}))

    const parsedUrl = parseUrl(this.url, true)
    delete parsedUrl.search
    parsedUrl.pathname += '/' + subPath
    parsedUrl.query['list[page]'] = 1
    parsedUrl.query['list[per_page]'] = 2
    parsedUrl.query['___sparse'] = sparseSpec

    const relationsUrl = buildUrl(parsedUrl)

    return this._runRequest(
      {
        url: relationsUrl,
        json: true
      },
      (err, res, json) => {
        if (err || res.statusCode >= 400) {
          console.error('Error fetching relations!', err || json)
          if (isFunction(callback)) {
            return callback(err || json)
          }
        }

        // update self with server response:
        const data = get(json, jsonPath)
        if (present(data)) {
          this.set(modelAttr, data)
        }
        if (isFunction(callback)) {
          return callback(err, data)
        }
      }
    );
  }
}
