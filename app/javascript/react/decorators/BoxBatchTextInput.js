import l from 'lodash'
import t from '../../lib/i18n-translate.js'
import cx from 'classnames/dedupe'
import async from 'async'
import url from 'url'
import xhr from 'xhr'
import getRailsCSRFToken from '../../lib/rails-csrf-token.js'


module.exports = ({event, data, initial, path, nextProps}) => {

  var next = () => {
    return {
      props: nextProps,
      path: path,
      data: {
        text: nextText()
      }
    }
  }


  var nextText = () => {

    if(initial) {
      return ''
    }

    if(event.action == 'change-text'){
      return event.text
    } else {
      return data.text
    }
  }

  return next()
}
