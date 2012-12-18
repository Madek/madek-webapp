class MetaTermsController< ApplicationController

  ##
  # returns a list of MetaTerms
  #
  # @resource /meta_terms
  #
  # @action GET
  #
  # @optional [integer] meta_key_id
  #
  # @response_field [integer] id    The id of the Keyword.
  # @response_field [string] value  The MetaTerm as string.
  #
  # @example_request {"meta_key_id": 4}
  # @example_request_description Request all MetaTerms associated to the MetaKey with id 4.
  # @example_response
  #   ```json
  #   [
  #     { 
  #       "id":1,
  #       "value":"Blue"
  #     },
  #     {
  #       "id":54,
  #       "value":"Red"
  #     },
  #     {
  #       "id":154,
  #       "value":"Yellow"
  #     }
  #   ]
  #   ```
  # @example_response_description The associated MetaKeys are "Blue", "Red" and "Yellow".
  #
  def index(meta_key_id = params[:meta_key_id], meta_context_id = params[:meta_context_id])
    if meta_key_id and meta_context_id
      meta_terms = MetaContext.find(meta_context_id).meta_keys.find(meta_key_id).meta_terms
      respond_to do |format|
        format.json { render :json => view_context.json_for(meta_terms) }
      end
    elsif meta_key_id
      meta_terms = MetaKey.find(meta_key_id).meta_terms
      respond_to do |format|
        format.json { render :json => view_context.json_for(meta_terms) }
      end
    else # its not yet possible to fetch meta terms without providing meta key id
      respond_to do |format|
        format.json { render :nothing => true, :status => :bad_request }
      end
    end
  end
end
