class FilterSet < ActiveRecord::Base

  include Concerns::Resources

  serialize :filter, JSON
end
