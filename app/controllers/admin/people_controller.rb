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

  def destroy
    ActiveRecord::Base.transaction do
      Person.find(params[:person_id]).destroy
    end
    redirect_to admin_people_path
  end

######
  
  def meta_data_transfer_form
    render layout: false
  end
  
  def meta_data_transfer
    person_originator= Person.find(params[:person_id])
    person_receiver= Person.find(params[:id_receiver])
    
    ActiveRecord::Base.transaction do
      person_receiver.meta_data << person_originator.meta_data
      person_originator.meta_data.destroy_all
    end

    redirect_to admin_people_path
  end
end
