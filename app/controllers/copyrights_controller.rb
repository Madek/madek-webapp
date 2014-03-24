class CopyrightsController< ApplicationController

  def index
    copyright_roots = Copyright.roots
    
    respond_to do |format|
      format.json { render :json => view_context.json_for(copyright_roots) }
    end
  end

end
