# -*- encoding : utf-8 -*-
class Admin::PeopleController < Admin::AdminController

  before_filter :pre_load

  def index
    @people = Person.order(:firstname)
  end

#  def show
#  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def update
    @person.update_attributes(params[:person])
    redirect_to admin_people_path
  end
  
#####################################################

  private

  def pre_load
      params[:person_id] ||= params[:id]
      @person = Person.find(params[:person_id]) unless params[:person_id].blank?
  end

end
