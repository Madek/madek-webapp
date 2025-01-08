# Concern: ResourceDeletable

module.exports =
  props:
    deleted:
      type: 'boolean'
      default: false

  # instance methods:
  delete: (callback)->
    @_runRequest(
      {method: 'DELETE', url: @url},
      (err, res, data)->
        if parseInt(res.statusCode) >= 400
          alert('Unexpected Error: ' + JSON.stringify(res))
        callback(err, res, data))
