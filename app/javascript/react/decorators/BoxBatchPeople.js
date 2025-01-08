import l from 'lodash'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import async from 'async'
import url from 'url'
import xhr from 'xhr'
import getRailsCSRFToken from '../../lib/rails-csrf-token.js'
import BoxBatchPeopleNewWidget from './BoxBatchPeopleNewWidget.js'

module.exports = (merged) => {

  let {event, data, components, initial, trigger, nextProps, path} = merged

  var next = () => {

    if(event.action == 'change-text') {
      loadKeywords()
    }

    return {
      props: nextProps,
      path: path,
      data: {
        text: nextText(),
        keywords: nextKeywords(),
        showProposals: nextShowProposals(),
        keywordProposals: nextKeywordProposals()
      },
      components: {
        newWidget: nextNewWidget()
      }
    }
  }

  var nextNewWidget = () => {

    var supportedTypes = l.filter(
      ['Person', 'PeopleGroup'],
      (t) => l.includes(nextProps.metaKey.allowed_people_subtypes, t)
    )

    if(l.isEmpty(supportedTypes)) {
      return null
    }

    var props = {
      metaKey: nextProps.metaKey
    }

    return BoxBatchPeopleNewWidget(
      {
        event: (initial || !components.newWidget ? {} : components.newWidget.event),
        trigger: trigger,
        initial: initial,
        components: (initial ? {} : components.newWidget.components),
        data: (initial ? {} : components.newWidget.data),
        nextProps: props,
        path: ['newWidget']
      }

    )
  }

  var nextText = () => {

    if(initial) {
      return ''
    }

    if(event.action == 'select-keyword' || event.action == 'close-proposals') {
      return ''
    }
    else if(event.action == 'change-text') {
      return event.text
    }
    else {
      return data.text
    }
  }

  var nextKeywords = () => {

    var keywordMatch = (k, r) => {
      if(k.id && r.id && k.id == r.id) {
        return true
      } else if(k.subtype == 'Person' && r.subtype == 'Person') {
        return k.first_name == r.first_name && k.last_name == r.last_name && k.pseudonym == r.pseudonym
      } else if(k.subtype == 'PeopleGroup' && r.subtype == 'PeopleGroup') {
        return k.first_name == r.first_name
      } else {
        return false
      }

    }


    if(initial) {
      return []
    }

    if(event.action == 'remove-keyword-by-id') {
      return l.filter(
        data.keywords,
        (k) => k.id != event.id
      )
    }
    else if(event.action == 'remove-keyword-by-data') {
      var r = event.keyword
      return l.reject(
        data.keywords,
        (k) => keywordMatch(k, r)
      )
    }
    else if(event.action == 'select-keyword') {
      return data.keywords.concat({
        id: event.keywordId,
        label: event.keywordLabel
      })
    }
    else if(components.newWidget && components.newWidget.event.action == 'add-person') {

      var person = components.newWidget.data.person
      if(l.isEmpty(person.firstname.trim()) && l.isEmpty(person.lastname.trim())) {
        return data.keywords
      }

      var newKeyword = l.omitBy(
        {
          subtype: 'Person',
          first_name: person.firstname.trim(),
          last_name: person.lastname.trim(),
          pseudonym: person.pseudonym.trim()
        },
        (v, k) => l.isNil(v) || v == ''
      )
      if(l.find(data.keywords, (k) => keywordMatch(k, newKeyword))) {
        return data.keywords
      } else {
        return data.keywords.concat(newKeyword)
      }
    }
    else if(components.newWidget && components.newWidget.event.action == 'add-group') {

      var group = components.newWidget.data.group
      if(l.isEmpty(group.name.trim())) {
        return data.keywords
      }

      var newKeyword = {
        subtype: 'PeopleGroup',
        first_name: group.name.trim()
      }
      if(l.find(data.keywords, (k) => keywordMatch(k, newKeyword))) {
        return data.keywords
      } else {
        return data.keywords.concat(newKeyword)
      }
    }
    else {
      return data.keywords
    }
  }

  var nextShowProposals = () => {

    if(initial) {
      return false
    }

    if(event.action == 'change-text' || (event.action == 'input-focus' && data.keywordProposals)) {
      return true
    }
    else if(event.action == 'close-proposals' || event.action == 'select-keyword') {
      return false
    }
    else {
      return data.showProposals
    }
  }

  var nextKeywordProposals = () => {

    if(initial) {
      return null
    }

    if(event.action == 'change-text' || event.action == 'select-keyword') {
      return null
    }
    else if(event.action == 'keywords-loaded') {
      return event.keywords
    }
    else {
      return data.keywordProposals
    }
  }

  var loadKeywords = () => {
    var url = '/people?search_term=' + encodeURIComponent(nextText()) + '&meta_key_id=' + encodeURIComponent(nextProps.metaKeyId)
    xhr(
      {
        url: url,
        method: 'GET',
        json: true,
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': getRailsCSRFToken()
        }
      },
      (err, res, json) => {
        if(err) {
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
