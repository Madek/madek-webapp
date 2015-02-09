class Vocable < ActiveRecord::Base

  include Concerns::Vocables::Filters

  belongs_to :meta_key
  has_and_belongs_to_many :meta_data

  def to_s
    term
  end
end
