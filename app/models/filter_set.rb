class FilterSet < ActiveRecord::Base

  include Concerns::EditSessions
  include Concerns::Entrust
  include Concerns::Favoritable
  include Concerns::MetaData
  include Concerns::PermissionsAssociations
  include Concerns::Users::Creator
  include Concerns::Users::Responsible

  serialize :filter, JSON
end
