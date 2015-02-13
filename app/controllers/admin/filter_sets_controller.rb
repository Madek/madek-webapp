class Admin::FilterSetsController < AdminController
  def index
    @filter_sets = FilterSet.page(params[:page]).per(16)
  end

  def show
    @filter_set = FilterSet.find params[:id]
    @user = @filter_set.responsible_user
  end
end
