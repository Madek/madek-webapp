class FilterSetsController < ApplicationController

  def create
    begin
      unless current_user
        render json: {}, status: :unauthorized
      else
        ActiveRecord::Base.transaction do
          @filter_set = FilterSet.create! user: current_user
          @filter_set.update_attributes params[:filter_set]
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
    @filter_set = FilterSet.where(:id => params[:id]).accessible_by_user(current_user,:view).first
  end

  def update
    begin
      ActiveRecord::Base.transaction do
        @filter_set=FilterSet.where(id: params[:id]).first
        if not @filter_set
          render json: {}, status: :not_found
        elsif current_user.authorized? :edit, @filter_set
          @filter_set.update_attributes! params[:filter_set]
          render json: @filter_set, status: :ok
        else
          render json: {}, status: :forbidden
        end
      end
    rescue => e
      render json: {}, status: :unprocessable_entity
    end
  end

#
#  def edit
#    if not @filter_set=FilterSet.where(id: params[:id]).first
#      render nil, status: 404
#    unless current_user.authorized? :edit, @filter_set
#      render 
#    else
#      render
#    end
#  end
end

