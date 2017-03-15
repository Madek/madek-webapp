class BatchController < ApplicationController
  include Concerns::MediaResources::PermissionsActions
  include Concerns::MediaResources::CrudActions
  include Concerns::MediaResources::CustomUrlsForController
  include Concerns::UserScopes::MediaResources

  include Modules::Batch::BatchAddToSet
  include Modules::Batch::BatchRemoveFromSet
  include Modules::Batch::BatchPermissionActions
  include Modules::Batch::BatchAddToClipboard

  def batch_add_to_clipboard
    batch_add_resources_to_clipboard(current_user, params)
  end

  def batch_remove_from_clipboard
    batch_remove_resources_from_clipboard(current_user, params)
  end
end
