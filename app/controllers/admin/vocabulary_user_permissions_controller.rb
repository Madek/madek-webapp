class Admin::VocabularyUserPermissionsController < AdminController
  include Concerns::Admin::VocabularyPermissions
  define_actions_for :user_permissions

  def index
    @user_permissions = @vocabulary.user_permissions.includes(:user)
  end

  def new
    @permission = Permissions::VocabularyUserPermission.new
    @permission.user_id = params[:user_id]
  end

  def destroy
    @vocabulary.user_permissions.destroy(params[:id])

    redirect_to admin_vocabulary_vocabulary_user_permissions_url,
                flash: {
                  success: 'The Vocabulary User Permission has been deleted.' }
  end

  private

  def permission_params
    params.require(:vocabulary_user_permission).permit(:user_id,
                                                       :use,
                                                       :view)
  end
end
