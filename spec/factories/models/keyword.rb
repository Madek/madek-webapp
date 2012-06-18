FactoryGirl.define do
  factory :keyword do
    user {FactoryGirl.create :user}
    meta_term {FactoryGirl.create :meta_term}
    meta_datum {FactoryGirl.create :meta_datum_keywords}
  end
end
