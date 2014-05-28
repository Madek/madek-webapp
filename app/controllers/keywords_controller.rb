class KeywordsController< ApplicationController

  def index
    query = params[:query]
    with = params[:with]

    keywords = Keyword.hacky_search(query).select "DISTINCT ON (keyword_term_id) * "

    respond_to do |format|
      format.json {
        # TODO sort directly on sql query
        render :json => view_context.hash_for(keywords, with).sort{|a,b| a[:label].downcase <=> b[:label].downcase}.to_json
      }
      format.html
    end
  end
    
end
