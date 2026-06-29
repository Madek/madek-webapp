/*
 * hashviz-svg.js
 * hashviz: build visual hash from input texts, in svg format
 */
import any_sha1 from 'any_sha1' // pick the right sha1 function in browsers/server
import hashblot from 'hashblot'

// give hashblot access to the sha1 function:
hashblot.bindSha1(any_sha1.from(any_sha1.utf8.bytes))

// svg (valid html5 node) with empty path, viewbox fits hashblot path size
const EMPTY_SVG = `<svg \
xmlns:xlink='http://www.w3.org/1999/xlink' \
xmlns='http://www.w3.org/2000/svg' \
viewBox='0 0 255 255'> \
<path id='p1' d='M 0 0'></path> \
</svg>`

const hashBlotPath = function (str) {
  if (typeof str === 'string') {
    return hashblot.sha1qpd(str)
  } else {
    return 'M 0 0'
  }
}

// Returns a native SVGElement (was previously a jQuery object)
const hashvizSvg = function (text) {
  const parser = new DOMParser()
  const doc = parser.parseFromString(EMPTY_SVG, 'image/svg+xml')
  const svg = doc.documentElement
  const path = svg.querySelector('path')
  const cleaned_text = typeof text.replace === 'function' ? text.replace(/\s\s/g, ' ') : undefined
  path.setAttribute('d', hashBlotPath(cleaned_text))
  return svg
}

export default hashvizSvg
