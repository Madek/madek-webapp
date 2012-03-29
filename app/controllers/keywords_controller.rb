class KeywordsController< ApplicationController

  ##
  # returns a list of Keywords
  #
  # @resource /keywords
  #
  # @action GET
  #
  # @example_request {}
  # @example_response  [{"id":1,"label":"Architekturtraktat"}]
  #
  # @response_field [integer] id    The id of the Keyword.
  # @response_field [string] label  The name of the Keyword.
  #
  def index
    @all_grouped_keywords = 
      if SQLHelper.adapter_is_mysql?
        Keyword.group(:meta_term_id)
      elsif SQLHelper.adapter_is_postgresql?
        Keyword.select "DISTINCT ON (meta_term_id) * "
      else
        raise "adapter is not supported"
      end

    respond_to do |format|
      format.json
    end
  end

end
