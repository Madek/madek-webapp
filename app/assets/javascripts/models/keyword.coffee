class Keyword

  constructor: (data)->
    for k,v of data
      @[k] = v

  @fetch: (term, callback)=>
    data = {with: {count: true, created_at: true, mine: true}} 
    $.extend data, {query: term} if term?
    $.ajax
      url: "/keywords.json"
      data: data
      success: (response)=>
        @currentKeywords = response unless term?
        callback(response) if callback?

  @mine: => _.filter @currentKeywords, (keyword)-> keyword.yours

  @top: => (_.sortBy @currentKeywords, (keyword)-> keyword.count).reverse()

  @latest: => (_.sortBy @currentKeywords, (keyword)-> moment(keyword.created_at).toDate()).reverse()

  @all: ()=> @currentKeywords

window.App.Keyword = Keyword