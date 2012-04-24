class MediaResourceArcsController < ApplicationController

  def get_arcs_by_parent_id
    begin
      @arcs = MediaResourceArc.where(parent_id: params[:parent_id])
      render :arcs
    rescue  Exception => e
      respond_to do |format|
        format.json { render json: e, status: :unprocessable_entity }
      end
    end
  end

  def update_arcs
    ActiveRecord::Base.transaction do

      begin 
        params[:media_resource_arcs].each do |arc_params| 
          MediaResourceArc \
            .where(parent_id: arc_params[:parent_id])
            .where(child_id: arc_params[:child_id])
            .first.update_attributes!(arc_params)
        end

        respond_to do |format|
          format.json { render json: {} }
        end

      rescue  Exception => e
        respond_to do |format|
          format.json { render json: e, status: :unprocessable_entity }
        end
      end

    end
  end

end


