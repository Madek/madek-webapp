class Userpermission < ActiveRecord::Base 
  belongs_to :user
  belongs_to :resource, :polymorphic => true

  has_one :mediaset_userpermission_join


end
