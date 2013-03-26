# -*- encoding : utf-8 -*-
class MetaDataController < ApplicationController

  def update
    if @media_resource = MediaResource.accessible_by_user(current_user, :edit) \
      .where(id: params[:media_resource_id]).first

      attributes = {meta_data_attributes: { '0' => 
        { meta_key_label: params[:id], value: params[:value]} }}

      ActiveRecord::Base.transaction do
        if @media_resource.update_attributes attributes
          @media_resource.editors << current_user
          @media_resource.touch
          render json: {}
        else
          render json: {}, status: :unprocessable_entity 
        end
      end
    else
      render json: {}, status: :not_allowed
    end
  end

  def update_multiple
    if @media_resource = MediaResource.accessible_by_user(current_user, :edit) \
      .where(id: params[:media_resource][:id]).first

      ActiveRecord::Base.transaction do
        if @media_resource.update_attributes params[:resource]
          @media_resource.editors << current_user
          @media_resource.touch
          flash[:notice] = "Die Änderungen wurden gespeichert."
        else
          flash[:error] = "Die Änderungen wurden nicht gespeichert."
        end
      end
      redirect_to @media_resource
    else
      not_authorized!
    end
  end

end
