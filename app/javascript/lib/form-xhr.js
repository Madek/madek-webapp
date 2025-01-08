/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
const xhr = require('xhr');
const getRailsCSRFToken = require('./rails-csrf-token.js');

module.exports = function(config, callback) {
  let {
    url
  } = config;
  let body = config.form.serialize();
  if (config.method === 'GET') {
    url = url + '?' + body;
    body = '';
  }

  return xhr(
    {
      method: config.method,
      url,
      body,
      headers: {
        'Accept': 'application/json',
        'Content-type': 'application/x-www-form-urlencoded',
        'X-CSRF-Token': getRailsCSRFToken()
      }
    },
    function(err, res, body) {

      let data;
      const errors = {
        headers: [],
        fields: {}
      };
      if (err) {
        console.error('Connection problem.', error);
        errors.headers.push('Connection problem.');
        callback('failure', errors);
        return;
      }

      try {
        data = JSON.parse(body);
      } catch (error1) {
        var error = error1;
        console.error('Cannot parse body of answer for meta data update', error);
        errors.headers.push('Cannot parse answer.');
        callback('failure', errors);
        return;
      }

      if (res.statusCode === 400) {
        errors.fields = data.errors;
        callback('failure', errors);
        return;
      }

      return callback('success', data);
  });
};
