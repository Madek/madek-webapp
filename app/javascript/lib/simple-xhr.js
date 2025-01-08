/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const xhr = require('xhr');
const getRailsCSRFToken = require('./rails-csrf-token.coffee');

module.exports = (config, callback) => xhr(
  {
    method: config.method,
    url: config.url,
    body: config.body,
    headers: {
      'Accept': 'application/json',
      'Content-type': 'application/x-www-form-urlencoded',
      'X-CSRF-Token': getRailsCSRFToken()
    }
  },
  function(err, res, body) {

    let error = null;
    if (err) {
      console.error('Connection problem.', err);
      error = 'Connection problem. ' + err;
      callback(error);
      return;
    }

    if (res.statusCode > 400) {
      console.error('System error.', res.statusCode);
      error = 'System error: ' + res.statusCode;
      callback(error);
      return;
    }

    return callback(error);
});
