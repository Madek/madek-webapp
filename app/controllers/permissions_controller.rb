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

    applications=  Array(params[:applications].is_a?(Hash) ? 
                         params[:applications].values : params[:applications])

    _media_resource_ids = Array(params[:media_resource_ids].is_a?(Hash) ? params[:media_resource_ids].values : params[:media_resource_ids])
    public_permission= params[:public]


    permissions_value_select_filter= lambda{|k,v| v.to_s == "true" || v.to_s == "false"}

    # filter the resources which the current user may manage 
    media_resource_ids = MediaResource.where(id: _media_resource_ids) \
      .accessible_by_user(current_user,:manage).pluck(:id)
    

    require 'set'

    ActiveRecord::Base.transaction do

      media_resource_ids = Set.new media_resource_ids
      affected_user_ids=  Set.new users.map{|up| up["id"]}
      affected_group_ids=  Set.new groups.map{|gp| gp["id"]}
      affected_application_ids= Set.new applications.map{|app| app["id"]}

      # destroy deleted or no more wanted user_permissions
      media_resource_ids.each do |mr_id| 
        existing_up_user_ids = Set.new Userpermission.where("media_resource_id= ?",mr_id).pluck(:user_id)
        (existing_up_user_ids - affected_user_ids).each do |uid|
          Userpermission.find_by(media_resource_id: mr_id, user_id: uid).destroy
        end
      end

      # create or update userpermission 
      media_resource_ids.each do |mr_id| 
        users.each do |newup| 
          Userpermission.find_or_create_by(
            media_resource_id: mr_id, 
            user_id: newup["id"]).update_attributes!(
              permit_permission_attributes(
                newup.select(&permissions_value_select_filter)))
        end
      end

      # destroy deleted no more wanted group_permissions
      media_resource_ids.each do |mr_id| 
        existing_gp_group_ids = Set.new Grouppermission.where("media_resource_id= ?",mr_id).pluck(:group_id)
        (existing_gp_group_ids - affected_group_ids).each do |gid|
          Grouppermission.find_by(media_resource_id: mr_id,group_id: gid).destroy
        end
      end

      # create or update grouppermission 
      media_resource_ids.each do |mr_id| 
        groups.each do |newup| 
          Grouppermission.find_or_create_by(
            media_resource_id: mr_id, 
            group_id: newup[:id]).update_attributes!(
              permit_permission_attributes( newup 
              .slice(*Grouppermission::ALLOWED_PERMISSIONS) 
              .select(&permissions_value_select_filter)))
        end
      end

      # destroy deleted or no more wanted application-permissions
      media_resource_ids.each do |mr_id| 
        existing_application_ids = Set.new API::Applicationpermission \
          .where("media_resource_id= ?",mr_id).pluck(:application_id)
        (existing_application_ids - affected_application_ids).each do |app_id|
          API::Applicationpermission.find_by(media_resource_id: mr_id, 
                                             application_id: app_id).destroy 
        end
      end


      # create or update application-permissions
      media_resource_ids.each do |mr_id| 
        applications.each do |new_app_perm| 
          API::Applicationpermission.find_or_create_by(
            media_resource_id:mr_id,
            application_id: new_app_perm[:id]).update_attributes!(
              permit_permission_attributes( new_app_perm 
                .slice(*API::Applicationpermission::ALLOWED_PERMISSIONS) 
                .select(&permissions_value_select_filter)))
        end
      end


      # update public permissions
      if public_permission
        media_resource_ids.each do |mr_id|
          MediaResource.find(mr_id).update_attributes!(
            permit_permission_attributes(
            public_permission 
              .slice(*MediaResource::ALLOWED_PERMISSIONS) 
              .select(&permissions_value_select_filter)))
        end
      end

      Userpermission.destroy_irrelevant
      Grouppermission.destroy_irrelevant
      API::Applicationpermission.destroy_irrelevant

    end

    flash[:notice] = "Zugriffsberechtigungen wurden gespeichert."

    render :json => {} 

  end



  def edit
    initilize_resources_and_more
    @data = {
      media_resource_id:  params[:media_resource_id],
      collection_id: params[:collection_id],
      manageable: @action == :edit,
      redirect_url: @save_link}
  end


  def permit_permission_attributes attributes
    # sometimes it has permit, sometimes not 
    # sort of a temporary solution
    attributes.permit(:view,:download,:edit,:manage) rescue attributes
  end

end
