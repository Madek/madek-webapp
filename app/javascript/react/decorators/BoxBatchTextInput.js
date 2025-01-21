module.exports = ({ event, data, initial, path, nextProps }) => {
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
    if (initial) {
      return ''
    }

    if (event.action == 'change-text') {
      return event.text
    } else {
      return data.text
    }
  }

  return next()
}
