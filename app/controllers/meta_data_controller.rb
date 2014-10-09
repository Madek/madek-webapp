# -*- encoding : utf-8 -*-
class MetaDataController < ApplicationController

  def update

    begin
      @media_resource = MediaResource.accessible_by_user(current_user, :edit) \
      .find(params[:media_resource_id])
    rescue ActiveRecord::RecordNotFound
      raise UserForbiddenError
    end
    attributes = {meta_data_attributes: { '0' => 
      { meta_key_label: params[:id], value: params[:value]} }}

    begin
      ActiveRecord::Base.transaction do
        if @media_resource.set_meta_data attributes
          @media_resource.editors << current_user
          @media_resource.touch
          render json: {}
        else
          render json: {}, status: :unprocessable_entity 
        end
      end
    rescue
      raise NotAllowedError
    end
  end

  def update_multiple
    begin 
      @media_resource = MediaResource.accessible_by_user(current_user, :edit) \
      .find(params[:media_resource][:id])
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
    rescue ActiveRecord::RecordNotFound 
      raise UserForbiddenError
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
      rescue
        raise UnprocessableEntityError
      end

      render json: {}, status: :ok
    else
      raise NotAllowedError
    end
  end

end
