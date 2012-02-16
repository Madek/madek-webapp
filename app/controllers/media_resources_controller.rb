# -*- encoding : utf-8 -*-
class MediaResourcesController < ApplicationController

  def update

    ActiveRecord::Base.transaction do

      begin

        @media_resource = MediaResource.find(params[:id])
        
        raise "user is not allowed to update resource" unless current_user == @media_resource.user

        if @media_resource.type == "MediaEntryIncomplete" and params[:media_resource][:type] == "MediaEntry"
          @media_resource.set_as_complete
        end

        @media_resource.update_attributes!(params[:media_resource])

        respond_to do |format|
          format.json { head :no_content }
        end

      rescue Exception => e

        respond_to do |format|
          format.json { render json: e, status: :unprocessable_entity }
        end

      end

    end

  end

end

