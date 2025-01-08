/*
 * decaffeinate suggestions:
 * DS101: Remove unnecessary use of Array.from
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
// Concern: ResourceWithRelations

const f = require('active-lodash');
const parseUrl = require('url').parse;
const buildUrl = require('url').format;

module.exports = {
  props: {
    parent_collections: ['object'],
    sibling_collections: ['object']
  },
    // NOTE: Collections also have:
    // child_media_resources: ['object']

  // instance methods:
  fetchRelations(type, callback){
    const validTypes = ['parent', 'sibling', 'child'];
    if (!f.include(validTypes, type)) { throw new Error('Invalid Relations type!'); }
    // NOTE: format: ['subpath_of_action', 'jsonPath.inside.presenter']
    //       last part of jsonpath is the key inside here…
    const supportedRelations = {
      parent: ['relations', 'relations.parent_collections'],
      sibling: ['relations', 'relations.sibling_collections'],
      child: ['', 'child_media_resources']
    };
    const [subPath, jsonPath] = Array.from(supportedRelations[type]);
    const modelAttr = f.last(jsonPath.split('.'));

    if (f.present(this.get(jsonPath))) { return; } // only fetch if missing

    const sparseSpec = JSON.stringify(f.set({}, jsonPath, {}));

    const parsedUrl = parseUrl(this.url, true);
    delete parsedUrl.search;
    parsedUrl.pathname += '/' + subPath;
    parsedUrl.query['list[page]'] = 1;
    parsedUrl.query['list[per_page]'] = 2;
    parsedUrl.query['___sparse'] = sparseSpec;

    const relationsUrl = buildUrl(parsedUrl);

    return this._runRequest({
      url: relationsUrl,
      json: true
    }, (err, res, json)=> {
      if (err || (res.statusCode >= 400)) {
        console.error('Error fetching relations!', err || json);
        if (f.isFunction(callback)) { return callback(err || json); }
      }

      // update self with server response:
      const data = f.get(json, jsonPath);
      if (f.present(data)) { this.set(modelAttr, data); }
      if (f.isFunction(callback)) { return callback(err, data); }
    });
  }
};
