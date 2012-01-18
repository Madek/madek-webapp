class Grouppermission < ActiveRecord::Base
  belongs_to :group
  belongs_to :media_resource, polymorphic: true

  delegate :name, to: :group

end
