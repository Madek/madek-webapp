class FilterSet < ActiveRecord::Base

  include Concerns::Entrust
  include Concerns::Favoritable
  include Concerns::EditSessions
  include Concerns::Permissions
  include Concerns::Users::Responsible
  include Concerns::Users::Creator
  include Concerns::Keywords

  serialize :filter, JSON
end
