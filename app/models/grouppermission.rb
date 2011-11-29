class Grouppermission < ActiveRecord::Base
  belongs_to :group
  belongs_to :resource, :polymorphic => true

end
