FactoryGirl.define do
  factory :keyword do
    user {FactoryGirl.create :user}
    meta_term {FactoryGirl.create :meta_term}
  end
end
