import l from 'lodash'
import xhr from 'xhr'
import getRailsCSRFToken from '../../lib/rails-csrf-token.coffee'

module.exports = merged => {
  let { event, data, initial, trigger, nextProps, path } = merged

  var next = () => {
    if (
      event.action == 'change-text' ||
      (event.action == 'input-focus' && nextProps.metaKey.show_checkboxes)
    ) {
      loadKeywords()
    }

    return {
      props: nextProps,
      path: path,
      data: {
        text: nextText(),
        keywords: nextKeywords(),
        showProposals: nextShowProposals(),
        keywordProposals: nextKeywordProposals(),
        keyCursor: nextKeyCursor(),
        option: nextOption()
      }
    }
  }

  var nextOption = () => {
    if (initial) {
      return 'add'
    } else if (event.action == 'change-option') {
      return event.option
    } else {
      return data.option
    }
  }

  var nextKeyCursor = () => {
    if (initial) {
      return -1
    }

    var proposals = nextKeywordProposals()

    if (!nextShowProposals()) {
      return -1
    } else if (!proposals || proposals.length == 0) {
      return -1
    }

    var limitCursor = nextValue => {
      if (nextValue >= proposals.length) {
        return proposals.length - 1
      } else if (nextValue < -1) {
        return -1
      } else {
        return nextValue
      }
    }

    if (event.action == 'cursor-down') {
      return limitCursor(data.keyCursor + 1)
    } else if (event.action == 'cursor-up') {
      return limitCursor(data.keyCursor - 1)
    } else {
      return limitCursor(data.keyCursor)
    }
  }

  var nextText = () => {
    if (initial) {
      return ''
    }

    if (
      (event.action == 'cursor-enter' && data.keyCursor == -1 && nextProps.metaKey.is_extensible) ||
      event.action == 'select-keyword' ||
      event.action == 'close-proposals'
    ) {
      return ''
    } else if (event.action == 'change-text') {
      return event.text
    } else {
      return data.text
    }
  }

  var nextKeywords = () => {
    if (initial) {
      return []
    }

    var existsAlready = () => {
      return !l.isEmpty(l.filter(data.keywords, kw => kw.id == event.keywordId))
    }

    if (event.action == 'remove-keyword-by-label') {
      return l.filter(data.keywords, k => k.label != event.label)
    } else if (event.action == 'remove-keyword-by-id') {
      return l.filter(data.keywords, k => k.id != event.id)
    } else if (
      event.action == 'cursor-enter' &&
      data.keyCursor == -1 &&
      nextProps.metaKey.is_extensible &&
      !l.isEmpty(data.text)
    ) {
      if (l.find(data.keywords, k => k.label == data.text)) {
        return data.keywords
      } else {
        return data.keywords.concat({
          label: data.text
        })
      }
    } else if (event.action == 'cursor-enter' && data.keyCursor != -1) {
      var keyword = nextKeywordProposals()[data.keyCursor]

      if (l.find(data.keywords, k => k.label == keyword.label)) {
        return data.keywords
      } else {
        return data.keywords.concat({
          id: keyword.uuid,
          label: keyword.label
        })
      }
    } else if (event.action == 'select-keyword' && !existsAlready()) {
      return data.keywords.concat({
        id: event.keywordId,
        label: event.keywordLabel
      })
    } else {
      return data.keywords
    }
  }

  var nextShowProposals = () => {
    if (initial) {
      return false
    }

    if (
      event.action == 'change-text' ||
      event.action == 'keywords-loaded' ||
      (event.action == 'input-focus' && data.keywordProposals)
    ) {
      return true
    } else if (event.action == 'close-proposals' || event.action == 'select-keyword') {
      return false
    } else {
      return data.showProposals
    }
  }

  var nextKeywordProposals = () => {
    if (initial) {
      return null
    }

    if (event.action == 'change-text' || event.action == 'select-keyword') {
      return null
    } else if (event.action == 'keywords-loaded') {
      return event.keywords
    } else {
      return data.keywordProposals
    }
  }

  var loadKeywords = () => {
    var url =
      '/keywords?search_term=' +
      encodeURIComponent(nextText()) +
      '&meta_key_id=' +
      encodeURIComponent(nextProps.metaKeyId)
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
            action: 'keywords-loaded',
            keywords: json
          })
        }
      }
    )
  }

  return next()
}
