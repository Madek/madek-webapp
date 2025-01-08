const getRailsCSRFToken = require('../../lib/rails-csrf-token.coffee');

module.exports = {
  ajaxConfig: {
    headers: {
      'Accept': 'application/json',
      'X-CSRF-Token': getRailsCSRFToken()
    }
  }
};
