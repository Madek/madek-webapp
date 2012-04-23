class MediaResourceArcsController < ApplicationController

  def get_arcs_by_parent_id
    @arcs = MediaResourceArc.where(parent_id: params[:parent_id])
    render :arcs
  end

  def update_arcs
  end

  def get_arc
    @arc = MediaResourceArc.where(parent_id: params[:parent_id]).where(child_id: params[:child_id]).first
    render :arc
  end

  def put_arc
  end

end


