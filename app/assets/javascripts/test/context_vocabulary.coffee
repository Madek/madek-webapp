window.Test.ContextVocabulary =

  all_unused_vocabulary_is_fade_out: ->
    
    return false
    # not _.any $(".ui-metadata-box ul li.ui-tag-cloud-item a").map ->
    #   state = $(this).hasClass 'disabled'
    #   if ($(this).data('term-count') == 0)
    #     state
    #   else
    #     not state
