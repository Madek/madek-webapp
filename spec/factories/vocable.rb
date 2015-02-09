FactoryGirl.define do
  factory :vocable do
    meta_key { FactoryGirl.create :meta_key_vocables }
    term { Faker::Lorem.word }
  end
end
