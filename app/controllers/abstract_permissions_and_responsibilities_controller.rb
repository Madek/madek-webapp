class AbstractPermissionsAndResponsibilitiesController < ApplicationController

  def responsible_users media_resources_ar
    User.where("id IN (#{media_resources_ar.select("user_id").to_sql})")
  end


  def initilize_resources_and_more
    @action = params['_action'].to_sym


    @all_media_resources= if params[:media_resource_id] # the case where we edit one 
                            MediaResource.where(id: params[:media_resource_id])
                          elsif params[:collection_id]
                            collection = Collection.get(params[:collection_id])
                            MediaResource.where("id IN (?)",collection[:ids])
                          else
                            raise "neither media_resource_id no collection_id given"
                          end

    @viewable_media_resources = @all_media_resources.accessible_by_user(current_user,:view)


    if @all_media_resources.count == 0 or @viewable_media_resources.count < @all_media_resources.count   
      redirect_to(my_dashboard_path, 
                  flash: {error: "You are not allowed to view all of the selected resources."})
      return 
    end

    @manageable_media_resources = @all_media_resources.accessible_by_user(current_user,:manage)


    # redirect and abort away under circumstances 
    if @all_media_resources.count == 0
      redirect_to(my_dashboard_path, 
                  flash: {error: "The collection is empty."})
      return
    end
    if @viewable_media_resources.count < @all_media_resources.count   
      redirect_to(my_dashboard_path, 
                  flash: {error: "You are not allowed to view all of the selected resources."})
      return
    end
    if @action == :edit and @manageable_media_resources.count == 0
      redirect_to(my_dashboard_path, 
                  flash: {error: "You are not allowed to manage any of the selected resources."})
      return
    end

    @media_resources= case @action
                      when :edit 
                        @manageable_media_resources
                      when :view
                        @viewable_media_resources
                      end

    @save_link = case @action
                 when :edit
                   if params[:media_resource_id]
                     view_context.edit_permissions_path(_action: 'view', media_resource_id: params[:media_resource_id])
                   elsif params[:collection_id]
                     view_context.edit_permissions_path(_action: "view",collection_id: params[:collection_id])
                   end
                 end

    @back_link= if params[:media_resource_id]
                  view_context.edit_permissions_path(_action: 'view', media_resource_id: params[:media_resource_id])
                elsif params[:collection_id]
                  view_context.edit_permissions_path(_action: "view",collection_id: params[:collection_id])
                else
                  my_dashboard_path
                end

    @responsible_users =responsible_users(@media_resources)

  end

end
