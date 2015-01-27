FactoryGirl.define do
  factory :keyword do
    user { FactoryGirl.create :user }
    keyword_term { FactoryGirl.create :keyword_term }
    meta_datum { FactoryGirl.create :meta_datum_keywords }
  end
end
