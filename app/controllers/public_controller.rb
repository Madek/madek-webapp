class PublicController < ActionController::Base

  def index
    redirect_to public_api_docs_path
  end

end
