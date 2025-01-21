import getRailsCSRFToken from '../../lib/rails-csrf-token.js'

module.exports = {
  ajaxConfig: {
    headers: {
      Accept: 'application/json',
      'X-CSRF-Token': getRailsCSRFToken()
    }
  }
}
