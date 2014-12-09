class MetaKey < ActiveRecord::Base

  has_many :meta_data, dependent: :destroy

end
