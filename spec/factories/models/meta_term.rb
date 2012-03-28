FactoryGirl.define do
  factory :meta_term do
    en_gb {Faker::Lorem.words.join(" ")}
    de_ch {Faker::Lorem.words.join(" ")}
  end
end
