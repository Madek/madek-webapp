class KeywordTerm < ActiveRecord::Base

  belongs_to :meta_key
  belongs_to :creator, class_name: User
  has_many :keywords

  def to_s
    term
  end

end
