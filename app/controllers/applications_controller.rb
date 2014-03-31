# -*- encoding : utf-8 -*-
class ApplicationsController < ApplicationController
  
  # This is just for our "internal API"
  respond_to :json
  
  def index
    query = params[:s] # search parameter
    limit = 5          # how many records per answer?
    whitelist = [:id]  # which properties are we allowed to send?
  
    if true # TODO: implement searching ¯\_(ツ)_/¯
      apps= API::Application.all
    else
      # @apps= API::Application.reorder(:autocomplete).where("autocomplete ilike ?","#{params[:search_term]}%").limit(limit)    
    end
  
    # clean up answer (no spilling secrets etc.)
    apps = apps.select(whitelist).limit(limit)  # TODO: fix whitelisting (rails magic?)

    # send answer
    respond_with(apps)
  end

end
