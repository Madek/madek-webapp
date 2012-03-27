class MetaTermController <  ApplicationController

  def context_keys_terms
    @meta_context= MetaContext.where("name = ?", params[:name]).first || MetaContext.where("id = ?",params[:name]).first
  end

end
