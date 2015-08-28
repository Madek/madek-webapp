class FilterSetsController < ApplicationController
  include Concerns::MediaResources::PermissionsActions
  include Concerns::MediaResources::ShowAction
end
