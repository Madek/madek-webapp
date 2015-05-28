class AppAdmin::UserpermissionsController < AppAdmin::BaseController

  def new
    @userpermission = Userpermission.new
    @media_set = MediaSet.find(params[:media_set_id])
  end

  def create
    media_set = MediaSet.find(params[:media_resource_id])
    user = User.find(params[:user_id])
    PermissionMaker.new(media_set, user, userpermission_params).call

    redirect_to app_admin_media_set_url(media_set), flash: {
      success: 'An user permission has been created.'
    }
  rescue => e
    redirect_to new_app_admin_userpermission_url(media_set_id: params[:media_resource_id]),
                flash: { error: e.to_s }
  end

  private

  def userpermission_params
    params.permit(userpermission: [ :view, :download, :edit ],
                  children_media_entries: [ :view, :download, :edit ],
                  children_media_sets: [ :view, :download, :edit ]
                 )
  end
end
