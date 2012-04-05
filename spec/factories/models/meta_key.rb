FactoryGirl.define do
  factory :meta_key do
    label {Faker::Lorem.words.join("_")}
  end
end
