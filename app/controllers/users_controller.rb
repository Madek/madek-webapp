# -*- encoding : utf-8 -*-
class UsersController < ApplicationController

  def index
    # OPTIMIZE add :user_id to Person#define_index and search :with => :user_id
    people = Person.search(params[:term]).select {|p| p.user }
    
    respond_to do |format|
      format.html
      format.js { render :json => people.map {|x| {:id => x.user.id, :value => x.to_s} } }
    end
  end

  def show
    # TODO refactor from ApplicationController#root
    redirect_to user_media_entries_path(params[:id])
  end

#####################################################

  def usage_terms
    theme "madek11"
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
