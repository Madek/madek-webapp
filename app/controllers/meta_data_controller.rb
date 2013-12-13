# -*- encoding : utf-8 -*-
class MetaDataController < ApplicationController

  def update
    if @media_resource = MediaResource.accessible_by_user(current_user, :edit) \
      .where(id: params[:media_resource_id]).first

      attributes = {meta_data_attributes: { '0' => 
        { meta_key_label: params[:id], value: params[:value]} }}

      ActiveRecord::Base.transaction do
        if @media_resource.set_meta_data attributes
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
        if @media_resource.set_meta_data params[:resource]
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

  def apply_to_all
    if not (@media_resources = MediaResource.accessible_by_user(current_user, :edit).where(:id => MediaResource.by_collection(params[:collection_id]))).blank?

      attributes = {meta_data_attributes: { '0' => 
        { meta_key_label: params[:id], value: params[:value]} }}
      if params[:overwrite] == "false"
        attributes[:meta_data_attributes]["0"][:keep_original_value_if_exists] = true
      end

      begin
        ActiveRecord::Base.transaction do
          @media_resources.each do |media_resource|

            if media_resource.set_meta_data attributes
              media_resource.editors << current_user
              media_resource.touch
            else
              raise media_resource.errors.full_messages.join(", ")
            end
          end
        end
      rescue => e
        render(json: {}, status: :unprocessable_entity) and return
      end

      render json: {}, status: :ok
    else
      render json: {}, status: :not_allowed
    end
  end

end
