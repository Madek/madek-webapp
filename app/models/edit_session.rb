class EditSession < ActiveRecord::Base

  belongs_to :user
  belongs_to :media_entry
  belongs_to :collection
  belongs_to :filter_set

  validates_presence_of :user

  validate :exactly_one_associated_resource_type

  default_scope { order('edit_sessions.created_at DESC') }

  def exactly_one_associated_resource_type
    errors.add :base, 'Edit session must belong to either media entry or collection or filter set.' unless (media_entry or collection or filter_set)
  end

end
