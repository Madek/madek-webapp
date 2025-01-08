import l from 'lodash'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import async from 'async'
import url from 'url'
import xhr from 'xhr'
import getRailsCSRFToken from '../../lib/rails-csrf-token.js'

module.exports = merged => {
  let { event, trigger, initial, components, data, nextProps, path } = merged

  var next = () => {
    if (nextProps.mount) {
      asyncLoadData('MediaEntry')
      asyncLoadData('Collection')
    }

    return {
      props: nextProps,
      path: path,
      data: {
        selectedTab: nextSelectedTab(),
        selectedVocabulary: nextSelectedVocabulary(),
        selectedTemplate: nextSelectedTemplate(),
        metaMetaData: nextData(),
        metaKeysWithTypes: nextMetaKeysWithTypes()
      },
      components: {}
    }
  }

  var nextSelectedVocabulary = () => {
    if (initial) {
      return null
    }

    if (event.action == 'select-vocabulary') {
      if (event.vocabulary == data.selectedVocabulary) {
        return null
      } else {
        return event.vocabulary
      }
    } else {
      return data.selectedVocabulary
    }
  }

  var nextSelectedTab = () => {
    if (initial) {
      return 'entries'
    }

    if (event.action == 'select-tab') {
      return event.selectedTab
    } else {
      return data.selectedTab
    }
  }

  var nextSelectedTemplate = () => {
    if (initial) {
      return null
    }

    if (event.action == 'select-template') {
      if (event.template == data.selectedTemplate) {
        return null
      } else {
        return event.template
      }
    } else {
      return data.selectedTemplate
    }
  }

  var nextMetaKeysWithTypes = () => {
    if (initial) {
      null
    }

    if (event.action == 'data-loaded' && nextData().length == 2) {
      var metaKeysWithTypes = metaMetaData => {
        var allMetaKeyIds = () => {
          return l.uniq(
            l.flatten(l.map(metaMetaData, mmd => l.keys(mmd.data.meta_key_by_meta_key_id)))
          )
        }

        var allMetaKeysById = () => {
          return l.reduce(
            metaMetaData,
            (memo, mmd) => {
              return l.merge(memo, mmd.data.meta_key_by_meta_key_id)
            },
            {}
          )
        }

        return l.map(allMetaKeyIds(), k => {
          return {
            metaKeyId: k,
            types: l.map(
              l.filter(metaMetaData, mmd => {
                return l.has(mmd.data.meta_key_by_meta_key_id, k)
              }),
              m => m.type
            ),
            metaKey: allMetaKeysById()[k],
            mandatoryByType: l.fromPairs(
              l.map(metaMetaData, mmd => [mmd.type, l.keys(mmd.data.mandatory_by_meta_key_id)])
            )
          }
        })
      }

      return metaKeysWithTypes(nextData())
    } else {
      return data.metaKeysWithTypes
    }
  }

  var nextData = () => {
    if (initial) {
      return []
    }

    if (event.action == 'data-loaded') {
      var entry = {
        data: event.data,
        type: event.type
      }
      if (event.type == 'Collection') {
        return data.metaMetaData.concat([entry])
      } else {
        return [entry].concat(data.metaMetaData)
      }
    } else {
      return data.metaMetaData
    }
  }

  var asyncLoadData = type => {
    var url = '/meta_meta_data?type=' + type
    xhr(
      {
        url: url,
        method: 'GET',
        json: true,
        headers: {
          Accept: 'application/json',
          'X-CSRF-Token': getRailsCSRFToken()
        }
      },
      (err, res, json) => {
        if (err) {
          return
        } else {
          trigger(merged, {
            action: 'data-loaded',
            type: type,
            data: json
          })
        }
      }
    )
  }

  return next()
}
