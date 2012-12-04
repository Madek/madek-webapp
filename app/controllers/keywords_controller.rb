class KeywordsController< ApplicationController

  ##
  # returns a list of Keywords
  #
  # @resource /keywords
  #
  # @action GET
  #
  # @optional [String] query The search query to find matching keywords 
  #
  # @example_request {}
  # @example_response  [{"id":1,"label":"Architekturtraktat"}]
  #
  # @example_request {"query": "architektur"}
  # @example_response [{"id":1,"label":"Architekturtraktat"},{"id":2,"label":"Architektur"},{"id":3,"label":"Landschaftsarchitektur"}] 
  #
  # @response_field [integer] id    The id of the Keyword.
  # @response_field [string] label  The name of the Keyword.
  #
  def index(query = params[:query],
            with = params[:with])

    keywords = Keyword.search(query).select "DISTINCT ON (meta_term_id) * "

    respond_to do |format|
      format.json {
        # TODO sort directly on sql query
        render :json => view_context.hash_for(keywords, with).sort{|a,b| a[:label].downcase <=> b[:label].downcase}.to_json
      }
      format.html
    end
  end
    
end
