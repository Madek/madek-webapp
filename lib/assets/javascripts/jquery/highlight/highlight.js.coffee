###

Highlight

This script provides functionalitites highlight inside of an element
found expressions are wraped with a span tag having the class "highlight" 

@params search_terms [Array] The given search_terms

###
$.extend $.fn,

  highlight: (search_terms) ->
    @each ->
      element = $(this)
      $(element).removeHighlights()
      sorted_terms = search_terms.sort (a,b) -> b.length - a.length
      regexp = new RegExp("\(\^\|\\s\)\("+sorted_terms.join("\|")+"\)", "gi")
      matches = $(this).html().match(regexp)
      if matches?
        sorted_matches = matches.sort (a,b) -> b.length - a.length
        $(sorted_matches).each (i, match) ->
          if (match != "")
            match_reg_exp = new RegExp(match, "gi")
            new_html = $(element).html().replace(match_reg_exp, "<span class='highlighted'>"+match+"</span>")
            $(element).html(new_html)

  removeHighlights: ->
    @each ->
      $(this).find(".highlighted").each (i, element) ->
        content = $(element).html().replace(/<span class='highlighted'>/g,"").replace(/<\/span>/g,"")
        $(element).before(content)
        $(element).remove()
         