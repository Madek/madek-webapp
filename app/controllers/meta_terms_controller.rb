class MetaTermsController< ApplicationController

  def index(meta_key_id = params[:meta_key_id], meta_context_name = params[:meta_context_name])
    if meta_key_id and meta_context_name
      meta_terms = MetaContext.find(meta_context_name).meta_keys.find(meta_key_id).meta_terms
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
