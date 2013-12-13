class ResponsibilitiesController < AbstractPermissionsAndResponsibilitiesController


  def edit
    initilize_resources_and_more
    @media_resources = @all_media_resources.accessible_by_user(current_user,:transfer)
  end

  def transfer

    @all_media_resources= if not params[:media_resource_id].blank? # the case where we edit one 
                            MediaResource.where(id: params[:media_resource_id])
                          elsif not params[:collection_id].blank?
                            collection = Collection.get(params[:collection_id])
                            MediaResource.where("id IN (?)",collection[:ids])
                          else
                            raise "neither media_resource_id no collection_id given"
                          end

    @transferableable_media_resources = @all_media_resources.accessible_by_user(current_user,:transfer)

    flash_message= 
      begin
        login_rex= /\[(.*)\]\s*$/
        login= login_rex.match(params[:user])[1] rescue nil
        new_user = User.find_by_login(login) or raise "Sie haben keine Person ausgewaehlt. Die Verantwortlichkeit konnte nicht uebertragen werden."

  
        MediaResource.transaction do
          Userpermission.destroy_irrelevant
          @transferableable_media_resources.each do |media_resource|
            previous_user= media_resource.user
            media_resource.update_attributes! user_id: new_user.id
            # slice is a workaround against parameter injection, use strong parameters once we are in Rails4
            Userpermission.create!(user_id: previous_user.id, media_resource_id: media_resource.id) \
              .update_attributes! params.require(:userpermission).permit(:view,:download,:edit,:manage)
          end
          Userpermission.destroy_irrelevant
        end

        {success: "Sie haben erfolgreich einer anderen Person die Verantwortlichkeit fuer die ausgewaehlten Inhalte uebertragen."}

      rescue Exception => e
        Rails.logger.warn Formatter.exception_to_log_s(e)
        {error: e.to_s}
      end

    @back_link= if not params[:media_resource_id].blank?
                  view_context.edit_permissions_path(_action: 'view', media_resource_id: params[:media_resource_id])
                elsif not params[:collection_id].blank?
                  view_context.edit_permissions_path(_action: "view",collection_id: params[:collection_id])
                else
                  my_dashboard_path
                end

    redirect_to @back_link, flash: flash_message

  end

end
