class Grouppermission < ActiveRecord::Base
  belongs_to :group
  belongs_to :media_resource

  delegate :name, to: :group

end
