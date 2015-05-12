class License < ActiveRecord::Base
  include Concerns::Licenses::Filters
end
