##
# Media resource arcs are the relations between media resources. Like a set has multiple media entries and a media entry can have multiple parent sets (Graph).   
# 
class MediaResourceArcsController < ApplicationController

  ##
  # Get media resource arcs:
  # 
  # @resource /media_resource_arcs/:parent_id(/:child_id)
  #
  # @action GET
  # 
  # @required [Integer] parent_id The id of the parent media resource (set).
  #
  # @optional [Integer] child_id The id of the child media resource (set/entry). 
  #
  # @example_request /media_resource_arcs/1
  # @example_request_description Request the media resources arcs for the media set with the id 1.
  # @example_response {"media_resource_arcs": [{"parent_id": 1, "child_id": 23, "highlight": false}, {"parent_id": 1, "child_id": 12, "highlight": true}]}
  # @example_response_description Returns two media resources arcs one is highlighted the other isnt.
  #
  # @response_field [Integer] parent_id The id of the parent media resource. 
  # @response_field [Integer] child_id The id of the child media resource. 
  # @response_field [Boolean] highlight A status indicator if the arc is highlighted or not. 
  #
  def get_arcs_by_parent_id
    @arcs = MediaResourceArc.where(parent_id: params[:parent_id])
    render :arcs
  end
  
  ##
  # Update media resource arcs:
  # 
  # @resource /media_resource_arcs
  #
  # @action PUT
  # 
  # @required [Array] media_resources_arcs The collection of media resources arcs which should be updated. 
  # @required [Integer] media_resources_arcs[].parent_id The parent id of the media_resource_arc. 
  # @required [Integer] media_resources_arcs[].child_id The child id of the media_resource_arc. 
  # @required [Boolean] media_resources_arcs[].highlight The highlight status of that media resource arc. 
  #
  # @example_request {"media_resource_arcs": [{"parent_id": 1, "child_id": 23, "higlight": true}]}
  # @example_request_description Set the highlight status for the arc between parent id 1 and child id 23 to true.
  # @example_response {}
  # @example_response_description Returns a Status: 200 (empty Hash).
  #
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


