import l from 'lodash'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import async from 'async'
import url from 'url'
import xhr from 'xhr'
import getRailsCSRFToken from '../../lib/rails-csrf-token.coffee'


module.exports = (last, props, trigger) => {

  var next = () => {

    if(props.event == 'try-fetch') {
      if(!last.fetching) {
        asyncLoadAll()
      }
    }

    if(!last) {
      return {
        fetching: false,
        queue: null,
        relations: {
          parents: null,
          children: null
        }
      }
    } else {
      return {
        fetching: nextFetching(),
        queue: nextQueue(),
        relations: nextRelations()
      }
    }
  }

  var nextQueue = () => {
    if(props.event == 'try-fetch') {
      if(last.fetching) {
        return last.queue
      } else {
        var typesToFetch = ['parents']
        if(props.resource.type == 'Collection') {
          typesToFetch.push('children')
        }
        return typesToFetch
      }

    } else if(props.event == 'relations-loaded') {
      return l.filter(last.queue, (q) => q != props.property)
    } else {
      return last.queue
    }
  }


  var nextFetching = () => {
    if(props.event == 'try-fetch') {
      return true
    } else if(props.event == 'relations-loaded') {
      return !l.isEmpty(nextQueue())
    } else {
      return last.fetching
    }
  }


  var nextRelations = () => {
    if(props.event == 'relations-loaded') {
      return {
        parents: (props.property == 'parents' ? props.relations : last.relations.parents),
        children: (props.property == 'children' ? props.relations : last.relations.children)
      }
    } else {
      return last.relations
    }
  }


  var asyncLoadAll = () => {
    l.each(
      nextQueue(),
      (q) => load(q, props.resource)
    )
  }


  var load = (property, resource) => {

    var jsonPaths = {
      parents: 'relations.parent_collections',
      children: 'child_media_resources'
    }

    var subPaths = {
      parents: 'relations',
      children: ''
    }

    var jsonPath = jsonPaths[property]

    var sparseSpec = JSON.stringify(l.set({}, jsonPath, {}))

    var parsedUrl = url.parse(resource.url, true)
    delete parsedUrl.search
    parsedUrl.pathname += '/' + subPaths[property]
    parsedUrl.query['list[page]'] = 1
    parsedUrl.query['list[per_page]'] = 2
    parsedUrl.query['___sparse'] = sparseSpec

    var relationsUrl = url.format(parsedUrl)

    xhr(
      {
        url: relationsUrl,
        json: true,
        headers: {
          'Accept': 'application/json',
          'X-CSRF-Token': getRailsCSRFToken()
        }
      },
      (err, res, json) => {
        var relations = l.get(json, jsonPath)
        trigger({
          event: 'relations-loaded',
          property: property,
          relations: relations
        })
      }
    )
  }



  return next()
}
