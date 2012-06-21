# -*- encoding : utf-8 -*-
class Admin::PeopleController < Admin::AdminController

  before_filter do
    unless (params[:person_id] ||= params[:id]).blank?
      @person = Person.find(params[:person_id])
    end
  end

#####################################################

  def index
    @people = Person.order(:firstname)
  end

#  def show
#  end

  def new
    @person = Person.new
  end
  
  def create
    Person.create(params[:person])
    redirect_to admin_people_path
  end

  def edit
    respond_to do |format|
      format.js
    end
  end

  def update
    @person.update_attributes(params[:person])
    redirect_to admin_people_path
  end
  
end
