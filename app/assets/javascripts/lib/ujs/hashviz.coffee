# hashviz: build visual hash from input texts (used on error pages)
# ujs usage: an svg is inserted in every <el data-hashviz-container="foo"> using
# text from first <el data-hashviz-target="foo"> as input for the hash

$ = require('jquery')
hashVizSVG = require('../hashviz-svg.coffee')

module.exports = hashvizUjs=()->
  # for all enabled containers:
  $('[data-hashviz-container]').each ->
    $container = $(this)
    # find source text, generate svg, replace container contents with it:
    name = $container.data('hashviz-container')
    text = $("[data-hashviz-target=#{name}]")?.first?()?.text?()
    $container?.html?(hashVizSVG(text))
