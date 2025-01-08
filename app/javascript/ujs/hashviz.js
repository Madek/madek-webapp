/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * DS103: Rewrite code to no longer use __guard__, or convert again using --optional-chaining
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/main/docs/suggestions.md
 */
// hashviz: build visual hash from input texts (used on error pages)
// ujs usage: an svg is inserted in every <el data-hashviz-container="foo"> using
// text from first <el data-hashviz-target="foo"> as input for the hash

let hashvizUjs;
const $ = require('jquery');
const hashVizSVG = require('../lib/hashviz-svg.js');

module.exports = (hashvizUjs=() => // for all enabled containers:
$('[data-hashviz-container]').each(function() {
  const $container = $(this);
  // find source text, generate svg, replace container contents with it:
  const name = $container.data('hashviz-container');
  const text = __guardMethod__(__guardMethod__($(`[data-hashviz-target=${name}]`), 'first', o1 => o1.first()), 'text', o => o.text());
  return __guardMethod__($container, 'html', o2 => o2.html(hashVizSVG(text)));
}));

function __guardMethod__(obj, methodName, transform) {
  if (typeof obj !== 'undefined' && obj !== null && typeof obj[methodName] === 'function') {
    return transform(obj, methodName);
  } else {
    return undefined;
  }
}
