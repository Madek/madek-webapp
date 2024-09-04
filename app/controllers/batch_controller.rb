class BatchController < ApplicationController
  include MediaResources::PermissionsActions
  include MediaResources::CrudActions
  include MediaResources::CustomUrlsForController
  include UserScopes::MediaResources

  include Modules::Batch::BatchAddToSet
  include Modules::Batch::BatchRemoveFromSet
  include Modules::Batch::BatchSoftDeleteResources
  include Modules::Batch::BatchPermissionActions
  include Modules::Batch::BatchAddToClipboard

  def batch_add_to_clipboard
    batch_add_resources_to_clipboard(current_user, params)
  end

  def batch_remove_from_clipboard
    batch_remove_resources_from_clipboard(current_user, params)
  end

  def batch_remove_all_from_clipboard
    batch_remove_all_resources_from_clipboard(current_user)
  end

end
