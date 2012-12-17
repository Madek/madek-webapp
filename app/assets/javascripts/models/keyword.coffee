class Keyword

  constructor: (data)->
    for k,v of data
      @[k] = v

  @fetch: (callback)=>
    $.ajax
      url: "/keywords.json"
      data: {with: {count: true, created_at: true, mine: true}} 
      success: (response)=>
        @currentKeywords = response
        callback(@currentKeywords) if callback?

  @mine: => _.filter @currentKeywords, (keyword)-> keyword.yours

  @top: => (_.sortBy @currentKeywords, (keyword)-> keyword.count).reverse()

  @latest: => (_.sortBy @currentKeywords, (keyword)-> moment(keyword.created_at).toDate()).reverse()

  @all: ()=> @currentKeywords

window.App.Keyword = Keyword