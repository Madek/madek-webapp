# hashviz: build visual hash from input texts, in svg format
$ = require('jquery')
any_sha1 = require('any_sha1') # pick the right sha1 function in browsers/server
hashblot = require('hashblot')

# give hashblot acces to the sha1 function:
hashblot.bindSha1(any_sha1.from(any_sha1.utf8.bytes))

# svg (valid html5 node) with empty path, viewbox fits hashblot path size
EMPTY_SVG = "<svg
          xmlns:xlink='http://www.w3.org/1999/xlink'
          xmlns='http://www.w3.org/2000/svg'
          viewBox='0 0 255 255'>
           <path id='p1' d='M 0 0'></path>
         </svg>"

hashBlotPath=(str)->
  if (typeof str == 'string') then hashblot.sha1qpd(str) else 'M 0 0'

module.exports = hashVizSVG=(text)->
  svg = $(EMPTY_SVG)
  path = svg.find('path')[0]
  cleaned_text = text.replace?(/\s\s/g, ' ')
  path.setAttribute('d', hashBlotPath(cleaned_text))
  svg
