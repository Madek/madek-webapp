# -*- encoding : utf-8 -*-
class ApplicationsController < ApplicationController
  
  # This is just for our "internal API"
  respond_to :json
  
  def index
    query = params[:s] # search parameter
    limit = 5          # how many records per answer?
    whitelist = [:id]  # which properties are we allowed to send?
  
      # binding.pry
      # if there is a query, we search, …
    if params[:query]
      apps= API::Application.where("id ilike ?","#{params[:query]}%")
    else
      # otherwise we list everything
      apps= API::Application.all
    end
  
    # clean up answer (no spilling secrets etc.)
    apps = apps.select(whitelist).limit(limit)  # TODO: fix whitelisting (rails magic?)

    # send answer
    respond_with(apps)
  end

end
