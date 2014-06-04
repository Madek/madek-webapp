class AppAdmin::PeopleController < AppAdmin::BaseController

  def index
    begin 
      @people = Person.page(params[:page]) 


      if !params[:is_group].blank?
        @people = @people.groups
      end

      if !params[:with_user].blank?
        @people = @people.joins(:user)
      end

      if !params[:with_meta_data].blank?
        @people = @people.joins(:meta_data).uniq
      end

      search_terms = params.try(:[],:filter).try(:[],:search_terms)

      if ! search_terms.blank?
        case params.try(:[], :sort_by) 
        when 'text_rank'
          @people= @people.text_rank_search(search_terms) \
            .order("last_name ASC, first_name ASC")
        when 'trgm_rank'
          @people= @people.trgm_rank_search(search_terms) \
            .order("last_name ASC, first_name ASC")
        else
          @people= @people.text_search(search_terms)
        end
      end

      case params.try(:[], :sort_by) || 'last_name_first_name'
      when 'last_name_first_name'
        @sort_by= :last_name_first_name
        @people= @people.reorder("last_name ASC, first_name ASC, pseudonym ASC")
      when 'trgm_rank'
        @sort_by = :trgm_rank
        raise "Search term must not be blank!" if search_terms.blank? 
      when 'text_rank'
        @sort_by = :text_rank
        raise "Search term must not be blank!" if search_terms.blank? 
      end

    rescue Exception => e
      @people = Person.where("true = false").page(params[:page])
      @error_message= e.to_s
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
      @person.update_attributes!(person_params)
      redirect_to app_admin_person_path(@person), flash: {success: "A person has been update"}
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

        meta_data_ids= person_receiver.meta_data.select('"meta_data"."id"')
        to_be_added= person_originator.meta_data.where(
          "id NOT IN (#{meta_data_ids.to_sql})")
        person_receiver.meta_data <<  to_be_added

        # TODO had to change this from person_originator.meta_data.clear to make the test pass in rails 4.0.1
        # as fare as I can see it still should have worked and would be preferable
        person_originator.meta_data.each {|md| person_originator.meta_data.delete md}
      end
      redirect_to app_admin_people_path, flash: {success: "The meta data has been transferred"}
    rescue => e
      redirect_to app_admin_people_path, flash: {error: e.to_s}
    end
  end

  def form_transfer_meta_data
    @person = Person.find  params[:id]
  end

  private

  def person_params
    params.require(:person).permit!
  end

end
