class IoInterface < ActiveRecord::Base
  has_many :io_mappings, :dependent => :destroy
  has_many :meta_keys, through: :io_mappings
end
