FactoryGirl.define do
  factory :keyword do
    user {FactoryGirl.create :user}
    keyword_term {FactoryGirl.create :keyword_term}
    media_entry {FactoryGirl.create :media_entry}
  end
end
