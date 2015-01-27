# -*- encoding : utf-8 -*-
class Keyword < ActiveRecord::Base

  belongs_to :user
  belongs_to :meta_datum
  belongs_to :keyword_term

  before_create do
    keyword_term.update!(creator: user) unless keyword_term.creator.present?
  end

  def to_s
    "#{keyword_term}"
  end

end
