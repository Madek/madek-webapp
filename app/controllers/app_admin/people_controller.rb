class AppAdmin::PeopleController < AppAdmin::BaseController

  def index
    @people = Person.reorder("last_name ASC, first_name ASC").page(params[:page]).per(12)

    if !params[:fuzzy_search].blank?
      @people = @people.fuzzy_search(params[:fuzzy_search])
    end

    if !params[:is_group].blank?
      @people = @people.groups
    end

    if !params[:with_user].blank?
      @people = @people.joins(:user)
    end

    if !params[:with_meta_data].blank?
      @people = @people.joins(:meta_data).uniq
    end

  end

  def show
    @person = Person.find params[:id]
  end


  def edit
    @person = Person.find params[:id]
  end

  def update
    begin
      @person = Person.find(params[:id])
      @person.update_attributes! params[:person]
      redirect_to app_admin_person_path(@person)
    rescue => e
      redirect_to edit_app_admin_person_path(@person), flash: {error: e.to_s}
    end
  end


  def destroy 
    begin 
      @person = Person.find(params[:id])
      @person.destroy
      raise @person.errors unless @person.destroyed?
      redirect_to app_admin_people_path, flash: {success: "A person has been destroyed"}
    rescue => e
      redirect_to app_admin_people_path, flash: {error: e.to_s} 
    end
  end

  def transfer_meta_data 
    begin
      person_originator= Person.find(params[:id])
      person_receiver= Person.find(params[:id_receiver])
      ActiveRecord::Base.transaction do
        person_receiver.meta_data << 
        person_originator.meta_data.where("id not in (#{person_receiver.meta_data.select('"meta_data"."id"').to_sql})")
        person_originator.meta_data.clear
      end
      redirect_to app_admin_people_path, flash: {success: "The meta data has been transfered"}
    rescue => e
      redirect_to app_admin_people_path, flash: {error: e.to_s}
    end
  end

  def form_transfer_meta_data
    @person = Person.find  params[:id]
  end

end
