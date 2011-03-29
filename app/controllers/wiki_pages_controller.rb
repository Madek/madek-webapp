class WikiPagesController < ApplicationController

  theme "madek11"
  
  acts_as_wiki_pages_controller


  #################### irwi callbacks ##################
  def show_allowed?
    true
  end

  def history_allowed?
    current_user.groups.is_member?("Admin") 
  end

  def edit_allowed?
    current_user.groups.is_member?("Admin") 
  end
  ############## end of: irwi callbacks ################
end
