class KeywordTerm < ActiveRecord::Base
  has_many :keywords

  def to_s
    term
  end
end
