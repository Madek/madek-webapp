import l from 'lodash'
import xhr from 'xhr'
import getRailsCSRFToken from '../../lib/rails-csrf-token.js'
import qs from 'qs'

module.exports = (batchComponent, resources, formData, trigger) => {
  applyMetaData(batchComponent, resources, formData, trigger)
}

var applyMetaData = (batchComponent, resources, formData, trigger) => {
  l.each(resources, r =>
    applyResourceMetaData({
      batchComponent: batchComponent,
      trigger: trigger,
      resource: r,
      formData: formData
    })
  )
}

var applyResourceMetaData = ({ batchComponent, trigger, resource, formData }) => {
  var resourceId = resource.uuid
  var resourceType = resource.type

  var mapScope = () => {
    return {
      MediaEntry: 'Entries',
      Collection: 'Sets'
    }[resourceType]
  }

  var pathType = () => {
    return {
      MediaEntry: 'entries',
      Collection: 'sets'
    }[resourceType]
  }

  var url = '/' + pathType() + '/' + resourceId + '/advanced_meta_data'

  var property = () => {
    return {
      MediaEntry: 'media_entry',
      Collection: 'collection'
    }[resourceType]
  }

  var formToDataText = data => {
    return [data.text]
  }

  var formToDataTextDate = data => {
    return [data.text]
  }

  var formToDataKeywords = data => {
    return l.map(data.keywords, k => {
      if (k.id) {
        return k.id
      } else {
        return {
          term: k.label
        }
      }
    })
  }

  var formToDataPeople = data => {
    return l.map(data.keywords, k => {
      if (k.id) {
        return k.id
      } else {
        return k
      }
    })
  }

  var formToData = fd => {
    return {
      'MetaDatum::Text': formToDataText,
      'MetaDatum::TextDate': formToDataTextDate,
      'MetaDatum::Keywords': formToDataKeywords,
      'MetaDatum::People': formToDataPeople
    }[fd.props.metaKey.value_type](fd.data)
  }

  var metaData = () => {
    return l.fromPairs(
      l.map(l.filter(formData, fd => l.includes(fd.props.metaKey.scope, mapScope())), fd => [
        fd.props.metaKeyId,
        {
          values: formToData(fd),
          options: fd.data.option ? { action: fd.data.option } : null
        }
      ])
    )
  }

  if (l.isEmpty(metaData())) {
    setTimeout(() => {
      trigger(batchComponent, {
        action: 'apply-success',
        resourceId: resource.uuid,
        thumbnailMetaData: null
      })
    }, 0)
    return
  }

  var data = {
    [property()]: {
      meta_data: metaData()
    }
  }

  var body = qs.stringify(data, {
    arrayFormat: 'brackets' // NOTE: Do it like rails.
  })

  resourceId = resource.uuid

  xhr(
    {
      url: url,
      method: 'PUT',
      body: body,
      headers: {
        Accept: 'application/json',
        'Content-type': 'application/x-www-form-urlencoded',
        'X-CSRF-Token': getRailsCSRFToken()
      }
    },
    (err, res) => {
      if (err || res.statusCode != 200) {
        trigger(batchComponent, { action: 'apply-failure', resourceId })
      } else {
        var thumbnailMetaData = () => {
          var getTitle = () => {
            var fd = l.find(formData, fd => fd.props.metaKeyId == 'madek_core:title')
            if (!fd) {
              return null
            } else {
              return fd.data.text
            }
          }
          var getAuthors = () => {
            var fd = l.find(formData, fd => fd.props.metaKeyId == 'madek_core:authors')
            if (!fd) {
              return null
            } else {
              return l.join(l.map(fd.data.keywords, k => k.label), '; ')
            }
          }
          return {
            title: getTitle(),
            authors: getAuthors()
          }
        }

        trigger(batchComponent, {
          action: 'apply-success',
          resourceId: resourceId,
          thumbnailMetaData: thumbnailMetaData()
        })
      }
    }
  )
}
