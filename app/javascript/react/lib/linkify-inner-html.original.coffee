linkifyStr = require('linkifyjs/string')

## build html string with auto-generated links
module.exports = (string)->
  {__html: linkifyStr(string,
    linkClass: 'link ui-link-autolinked'
    linkAttributes:
      rel: 'nofollow'
    target: '_self'
    nl2br: true # also takes care of linebreaks…
    validate: { # only linkyify if it starts with 'http://' (etc) or 'www.'
      url: (string) -> /^((http|ftp)s?:\/\/|www\.)/.test(string)
    },
    format: (value, type)->
      if (type == 'url' && value.length > 50)
        value = value.slice(0, 50) + '…'
      return value)}
