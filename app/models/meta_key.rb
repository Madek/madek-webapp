class MetaKey < ActiveRecord::Base

  has_many :meta_data, dependent: :destroy
  has_many :vocables
  belongs_to :vocabulary

end
