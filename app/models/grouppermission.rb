class Grouppermission < ActiveRecord::Base
  belongs_to :group
  belongs_to :media_resource, polymorphic: true
  belongs_to :permissionset

  after_destroy {|r| r.permissionset.destroy if r.permissionset}

  delegate :name, to: :group

end
