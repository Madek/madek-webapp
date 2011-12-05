class MediasetUserpermissionJoin < ActiveRecord::Base
  belongs_to :media_set
  belongs_to :userpermission
end
