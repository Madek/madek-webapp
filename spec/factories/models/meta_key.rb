FactoryGirl.define do
  factory :meta_key do
    label { Faker::Lorem.words.join("_") }
    meta_datum_object_type { "MetaDatumString" }
    is_dynamic { nil }
  end
end
