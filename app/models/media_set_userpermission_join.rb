class MediaSetUserpermissionJoin < ActiveRecord::Base
  belongs_to :media_set, :class_name => "Media::Set"
  belongs_to :userpermission
end
