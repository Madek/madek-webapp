# -*- encoding : utf-8 -*-

##
# Permissions are actions that specify if or if not a subject can perform those actions on a specific resource.
# Possible actions are: view, edit, manage, download
# 
class PermissionsController < AbstractPermissionsAndResponsibilitiesController

  def index(media_resource_ids = (params[:collection_id] ? MediaResource.by_collection(params[:collection_id]) : params[:media_resource_ids]))
    begin
      media_resources = MediaResource.accessible_by_user(current_user, :view).find(media_resource_ids)
      render :json => view_context.hash_for_permissions_for_media_resources(media_resources, params[:with]).to_json
    rescue Exception => e
      # TODO yet another `not_authorized!` shadowing proper response codes 
      not_authorized!
    end
  end


  def update

    groups= Array(params[:groups].is_a?(Hash) ? params[:groups].values : params[:groups])
    users = Array(params[:users].is_a?(Hash) ? params[:users].values : params[:users])
    _media_resource_ids = Array(params[:media_resource_ids].is_a?(Hash) ? params[:media_resource_ids].values : params[:media_resource_ids])
    public_permission= params[:public]


    # filter the resources which the current user may manage 
    media_resource_ids = MediaResource.where(id: _media_resource_ids) \
      .accessible_by_user(current_user,:manage).pluck(:id)
    

    require 'set'

    ActiveRecord::Base.transaction do

      media_resource_ids = Set.new media_resource_ids
      affected_user_ids=  Set.new users.map{|up| up["id"]}
      affected_group_ids=  Set.new groups.map{|gp| gp["id"]}

      # destroy deleted or no more wanted user_permissions
      media_resource_ids.each do |mr_id| 
        existing_up_user_ids = Set.new Userpermission.where("media_resource_id= ?",mr_id).pluck(:user_id)
        (existing_up_user_ids - affected_user_ids).each do |uid|
          Userpermission.where("media_resource_id= ?",mr_id).where("user_id = ?",uid).first.destroy
        end
      end

      # create or update userpermission 
      media_resource_ids.each do |mr_id| 
        users.each do |newup| 
          uid= newup[:id]
          up = Userpermission.where("media_resource_id= ?",mr_id).where("user_id = ?",uid).first || (Userpermission.new user_id: uid, media_resource_id: mr_id)
          up.update_attributes! newup.select{|k,v| v.to_s == "true" || v.to_s == "false"}
        end
      end

      # destroy deleted or no more wanted group_permissions
      media_resource_ids.each do |mr_id| 
        existing_gp_group_ids = Set.new Grouppermission.where("media_resource_id= ?",mr_id).pluck(:group_id)
        (existing_gp_group_ids - affected_group_ids).each do |gid|
          Grouppermission.where("media_resource_id= ?",mr_id).where("group_id = ?",gid).first.destroy
        end
      end

      # create or update grouppermission 
      media_resource_ids.each do |mr_id| 
        groups.each do |newup| 
          uid= newup[:id]
          up = Grouppermission.where("media_resource_id= ?",mr_id) \
            .where("group_id = ?",uid).first || (Grouppermission.new group_id: uid, media_resource_id: mr_id)
          up.update_attributes! newup.slice(:view,:download,:edit).select{|k,v| v.to_s == "true" || v.to_s == "false"}
        end
      end

      # update public permissions
      if public_permission
        media_resource_ids.each do |mr_id|
          MediaResource.find(mr_id).update_attributes! \
            public_permission.slice(:view,:download).select{|k,v| v.to_s == "true" or  v.to_s == "false"}
        end
      end

      Userpermission.destroy_irrelevant
      Grouppermission.destroy_irrelevant

    end

    flash[:notice] = "Zugriffsberechtigungen wurden gespeichert."
    respond_to do |format|
      format.json { render :json => {} }
    end

  end



  def edit
    initilize_resources_and_more
    @data = {
      media_resource_id:  params[:media_resource_id],
      collection_id: params[:collection_id],
      manageable: @action == :edit,
      redirect_url: @save_link}
  end

end
