class CustomUrl < ActiveRecord::Base
  belongs_to :media_resource
  belongs_to :creator, class_name: 'User', foreign_key: :creator_id
  belongs_to :updator, class_name: 'User', foreign_key: :updator_id

  default_scope lambda{order(id: :asc)}
end
