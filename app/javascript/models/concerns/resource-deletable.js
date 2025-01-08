/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
// Concern: ResourceDeletable

module.exports = {
  props: {
    deleted: {
      type: 'boolean',
      default: false
    }
  },

  // instance methods:
  delete(callback){
    return this._runRequest(
      {method: 'DELETE', url: this.url},
      function(err, res, data){
        if (parseInt(res.statusCode) >= 400) {
          alert('Unexpected Error: ' + JSON.stringify(res));
        }
        return callback(err, res, data);
    });
  }
};
