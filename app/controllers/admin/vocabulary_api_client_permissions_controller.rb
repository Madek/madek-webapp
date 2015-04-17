class Admin::VocabularyApiClientPermissionsController < AdminController
  include Concerns::Admin::VocabularyPermissions
  define_actions_for :api_client_permissions

  def index
    @api_client_permissions =
      @vocabulary.api_client_permissions.includes(:api_client)
  end

  def new
    @permission =
      Permissions::VocabularyApiClientPermission.new
    @permission.api_client_id = params[:api_client_id]
  end

  def destroy
    @vocabulary.api_client_permissions.destroy(params[:id])

    redirect_to(
      admin_vocabulary_vocabulary_api_client_permissions_url,
      flash: {
        success: 'The Vocabulary API Client Permission has been deleted.' }
    )
  end

  private

  def permission_params
    params.require(:vocabulary_api_client_permission).permit(:api_client_id,
                                                             :use,
                                                             :view)
  end
end
