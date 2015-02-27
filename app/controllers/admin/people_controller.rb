class Admin::PeopleController < AdminController
  def index
    @people = Person.page(params[:page]).per(16)

    if params[:search_term].present?
      @people = @people.search_by_term(params[:search_term])
    end
    @people = @people.with_user if params[:with_user] == '1'
  end

  def show
    @person = Person.find(params[:id])
  end

  def edit
    @person = Person.find(params[:id])
  end

  def new
    @person = Person.new
  end

  def update
    find_person
    @person.update!(person_params)

    redirect_to admin_person_path(@person), flash: {
      success: 'The person has been updated.'
    }
  rescue => e
    redirect_to edit_admin_person_path(@person), flash: { error: e.to_s }
  end

  def create
    @person = Person.new(person_params)
    @person.save!

    redirect_to admin_people_path, flash: {
      success: 'The person has been created.'
    }
  rescue => e
    flash.now[:error] = e.to_s
    render :new
  end

  def destroy
    find_person
    @person.destroy!

    redirect_to admin_people_path, flash: {
      success: 'The person has been deleted.'
    }
  rescue => e
    redirect_to admin_person_path(@person), flash: { error: e.to_s }
  end

  private

  def find_person
    @person = Person.find(params[:id])
  end

  def person_params
    params.require(:person).permit!
  end
end
