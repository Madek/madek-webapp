# -*- encoding : utf-8 -*-
class UsersController < ApplicationController

  ##
  # Get a collection of Users
  # 
  # @resource /users
  #
  # @action GET
  # 
  # @optional [String] query The search query to find matching users 
  # @optional [Integer] exclude_group_id The id of the group to exclude the members from the result 
  #
  # @example_request {}
  # @example_response [{"id":1,"name":"Sellitto, Franco"},{"id":2,"name":"Pape, Sebastian"}] 
  #
  # @example_request {"query": "franco"}
  # @example_response [{"id":1,"name":"Sellitto, Franco"}] 
  #
  # @example_request {"exclude_group_id": 1} 
  # @example_request_description Assuming that Franco is member of group_id 1
  # @example_response [{"id":2,"name":"Pape, Sebastian"}] 
  #
  def index(query = params[:query],
            exclude_group_id = params[:exclude_group_id])
    respond_to do |format|
      format.json {
        @users = Person.search(query).map(&:user).compact
        
        if exclude_group_id
          group = Group.find(exclude_group_id)
          @users -= group.users
        end
      }
    end
  end

  def show
    # TODO refactor from ApplicationController#root
    redirect_to media_resources_path(:user_id => params[:id])
  end

#####################################################

  def usage_terms
    if request.post?
      # OPTIMIZE check if really submitted the form (hidden variable?)
      current_user.usage_terms_accepted!
      redirect_to root_path
    else
      @usage_term = UsageTerm.current
      
      @title = "Medienarchiv der Künste: #{@usage_term.title}"
      @disable_user_bar = true
      @disable_search = true
    end
  end

end
