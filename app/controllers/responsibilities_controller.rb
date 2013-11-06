class ResponsibilitiesController < ApplicationController

  def init_multiple
    @collection = Collection.get(params[:collection_id])
    @all_media_resources = MediaResource.where("id IN (?)",@collection[:ids])
    @media_resources= @all_media_resources.accessible_by_user(current_user,:transfer)
    @back_link= view_context.my_dashboard_path
  end

  def init_single
    @media_resources= MediaResource.where(id: params[:media_resource_id]).accessible_by_user(current_user,:transfer)
    @back_link = view_context.media_resource_path(@media_resources.first) rescue my_dashboard_path
  end

  def edit
    if not params[:media_resource_id].blank? # the case where we edit one 
      init_single
    elsif params[:collection_id]
      init_multiple
    else
      raise "neither media_resource_id no collection_id given"
    end
  end


  def update

    flash_message= 
      begin
        login_rex= /\[(.*)\]\s*$/
        login= login_rex.match(params[:user])[1] rescue nil
        new_user = User.find_by_login(login) or raise "Could not find target user"
        if not params[:media_resource_id].blank? # the case where we edit one 
          init_single
        elsif params[:collection_id]
          init_multiple
        else
          raise "neither media_resource_id no collection_id given"
        end

        MediaResource.transaction do
          Userpermission.destroy_irrelevant
          @media_resources.each do |media_resource|
            previous_user= media_resource.user
            media_resource.update_attributes! user_id: new_user.id
            # TODO this is vulnerable to parameter injection, fix with Strong parameters in Rails4
            Userpermission.create!(user_id: previous_user.id, media_resource_id: media_resource.id) \
              .update_attributes! params[:userpermission]
          end
          Userpermission.destroy_irrelevant
        end

        {success: "The responsibility of the media_resources have been transfered."}

      rescue Exception => e
        {error: e.to_s}
      end


    if @back_link 
      redirect_to @back_link, flash: flash_message
    else
      redirect_to my_dashboard_path, flash: flash_message
    end
  end

end
