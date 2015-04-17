class Admin::VocabularyGroupPermissionsController < AdminController
  include Concerns::Admin::VocabularyPermissions
  define_actions_for :group_permissions

  def index
    @group_permissions = @vocabulary.group_permissions.includes(:group)
  end

  def new
    @permission = Permissions::VocabularyGroupPermission.new
    @permission.group_id = params[:group_id]
  end

  def destroy
    @vocabulary.group_permissions.destroy(params[:id])

    redirect_to admin_vocabulary_vocabulary_group_permissions_url,
                flash: {
                  success: 'The Vocabulary Group Permission has been deleted.' }
  end

  private

  def permission_params
    params.require(:vocabulary_group_permission).permit(:group_id,
                                                        :use,
                                                        :view)
  end
end
