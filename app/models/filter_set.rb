class FilterSet < ActiveRecord::Base

  include Concerns::MediaResources

  serialize :filter, JSON
end
