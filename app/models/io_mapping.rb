class IoMapping < ActiveRecord::Base
  belongs_to :io_interface
  belongs_to :meta_key
end
