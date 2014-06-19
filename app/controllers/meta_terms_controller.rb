class MetaTermsController< ApplicationController

  def index(meta_key_id = params[:meta_key_id], context_id = params[:context_id])
    if meta_key_id and context_id
      meta_terms = Context.find(context_id).meta_keys.find(meta_key_id).meta_terms
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
