window.Test.ContextVocabulary =

  all_unused_vocabulary_is_fade_out: ->
    not _.any $(".ui-metadata-box ol li:not([data-is-used])"), (el)->
      not parseInt($(el).css('opacity')) < 1