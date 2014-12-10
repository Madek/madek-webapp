# -*- encoding : utf-8 -*-
class Keyword < ActiveRecord::Base

  belongs_to :user
  belongs_to :keyword_term
  belongs_to :media_entry
  belongs_to :collection
  belongs_to :filter_set

  before_create do
    keyword_term.update!(creator: user) unless keyword_term.creator.present?
  end

  def to_s
    "#{keyword_term}"
  end

end
