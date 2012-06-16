class CopyrightsController< ApplicationController

  ##
  # returns a collection of predefined copyright settings 
  #
  # @resource /copyrights
  #
  # @action GET
  #
  def index
    copyright_roots = Copyright.roots
    
    respond_to do |format|
      format.json { render :json => view_context.json_for(copyright_roots) }
    end
  end

end
