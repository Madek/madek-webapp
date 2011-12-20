class MediaSetsGrouppermissionsJoin < ActiveRecord::Base
  belongs_to :media_set, :class_name => "Media::Set"
  belongs_to :grouppermission
end

