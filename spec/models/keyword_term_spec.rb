require 'spec_helper'

describe KeywordTerm do
  describe '#creator' do
    it 'returns an user who created a keyword term' do
      keyword_term = FactoryGirl.create :keyword_term
      creator_user = FactoryGirl.create :user
      common_user  = FactoryGirl.create :user

      FactoryGirl.create :keyword, user: creator_user, keyword_term: keyword_term
      FactoryGirl.create :keyword, user: common_user,  keyword_term: keyword_term

      expect(keyword_term.reload.creator).to eq(creator_user)
    end
  end
end
