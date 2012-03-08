# -*- encoding : utf-8 -*-
class UsersController < ApplicationController

  # only used for jquery-autocomplete ?? 
  def index
    people = Person.search(params[:term])
    users = people.map(&:user).compact
    
    if params[:group_id]
      group = Group.find(params[:group_id])
      users -= group.users
    end
    
    respond_to do |format|
      format.html
      format.json { render :json => users.map {|x| {:id => x.id, :value => x.to_s} } }
    end
  end

  def show
    # TODO refactor from ApplicationController#root
    redirect_to user_resources_path(params[:id])
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
