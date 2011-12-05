class MediaentryUserpermissionJoin < ActiveRecord::Base
  belongs_to :media_entry
  belongs_to :userpermission
end
