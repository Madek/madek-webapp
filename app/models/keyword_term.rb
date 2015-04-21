class KeywordTerm < ActiveRecord::Base

  include Concerns::KeywordTerms::Filters

  belongs_to :meta_key
  belongs_to :creator, class_name: User
  has_many :keywords

  def to_s
    term
  end

end
