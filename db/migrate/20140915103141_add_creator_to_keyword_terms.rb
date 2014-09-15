class AddCreatorToKeywordTerms < ActiveRecord::Migration
  def change
    add_column :keyword_terms, :creator_id, :uuid
    KeywordTerm.all.each do |keyword_term|
      keyword_term.update_attribute(:creator_id, creator_id(keyword_term))
    end
  end

  def creator_id(keyword_term)
    keyword_term.keywords.order(:created_at).first.user.id rescue nil
  end
end
