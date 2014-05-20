class FilterSetsController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  def record_not_found
    render text: "404 Not Found", status: 404
  end

  include Concerns::PreviousIdRedirect
  include Concerns::CustomUrls

  def check_and_initialize_for_view
    @filter_set = find_media_resource 
    raise "Wrong type" unless @filter_set.is_a? FilterSet
    raise UserForbiddenError unless current_user.authorized?(:view,@filter_set)
  end

  def create
    begin
      unless current_user
        render json: {}, status: :unauthorized
      else
        ActiveRecord::Base.transaction do
          @filter_set = FilterSet.create! user: current_user
          @filter_set.update_attributes params["filter_set"].slice("settings").permit!
          @filter_set.set_meta_data  params["filter_set"].slice("meta_data_attributes").permit!
          raise @filter_set.errors.full_messages.join(", ") unless @filter_set.valid?
          render json: @filter_set, status: :created
        end
      end
    rescue => e
      logger.error e
      render json: {}, status: :unprocessable_entity
    end
  end

  def edit 
    @filter_set = FilterSet.where(:id => params[:id]).accessible_by_user(current_user, :edit).first
    render status: :not_found unless @filter_set
  end

  def show 
    check_and_initialize_for_view
  end

  def update
    ActiveRecord::Base.transaction do
      @filter_set=FilterSet.where(id: params[:id]).first
      if not @filter_set
        render json: {}, status: :not_found
      elsif current_user.authorized? :edit, @filter_set
        @filter_set.update_attributes! permitted_update_params
        render json: @filter_set, status: :ok
      else
        render json: {}, status: :forbidden
      end
    end
  end

  private

  def permitted_update_params
    params[:filter_set].select{|k,v| k=='settings'}.permit!
  end

end

