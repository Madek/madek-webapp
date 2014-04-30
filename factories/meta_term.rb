FactoryGirl.define do
  factory :meta_term do
    term {Faker::Lorem.words.join(" ")}
  end
end
