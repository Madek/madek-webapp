class FullText < ActiveRecord::Base
  
  belongs_to :resource, :polymorphic => true #-# TODO store real subclass type

end
