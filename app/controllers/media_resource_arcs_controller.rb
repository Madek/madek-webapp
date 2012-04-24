class MediaResourceArcsController < ApplicationController

  def get_arcs_by_parent_id
    @arcs = MediaResourceArc.where(parent_id: params[:parent_id])
    render :arcs
  end

  def update_arcs
    ActiveRecord::Base.transaction do

      begin 
        params[:arcs].each do |arc_params| 
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

  def get_arc
    @arc = MediaResourceArc.where(parent_id: params[:parent_id]).where(child_id: params[:child_id]).first
    render :arc
  end

end


