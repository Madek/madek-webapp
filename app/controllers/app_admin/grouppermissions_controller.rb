class AppAdmin::GrouppermissionsController < AppAdmin::BaseController

  def new
    @grouppermission = Grouppermission.new
    @media_set = MediaSet.find(params[:media_set_id])
  end

  def create
    media_set = MediaSet.find(params[:media_resource_id])
    group = Group.find(params[:group_id])
    PermissionMaker.new(media_set, group, grouppermission_params).call

    redirect_to app_admin_media_set_url(media_set), flash: {
      success: 'A group permission has been created.'
    }
  rescue => e
    redirect_to new_app_admin_grouppermission_url(media_set_id: params[:media_resource_id]),
                flash: { error: e.to_s }
  end

  private

  def grouppermission_params
    params.permit(grouppermission: [ :view, :download, :edit ],
                  children_media_entries: [ :view, :download, :edit ],
                  children_media_sets: [ :view, :download, :edit ]
                 )
  end
end
