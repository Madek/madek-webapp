class BatchController < ApplicationController
  include Concerns::MediaResources::PermissionsActions
  include Concerns::MediaResources::CrudActions
  include Concerns::MediaResources::CustomUrlsForController
  include Concerns::UserScopes::MediaResources

  include Modules::Batch::BatchAddToSet

end
