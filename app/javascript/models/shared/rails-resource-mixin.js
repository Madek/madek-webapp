import getRailsCSRFToken from '../../lib/rails-csrf-token.js'

export default {
  ajaxConfig: {
    headers: {
      Accept: 'application/json',
      'X-CSRF-Token': getRailsCSRFToken()
    }
  }
}
