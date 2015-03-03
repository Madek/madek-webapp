FactoryGirl.define do

  factory :vocabulary do
    id { Faker::Internet.slug }
    label { Faker::Lorem.word }
    description { Faker::Lorem.sentence }

    factory :vocabulary_for_vocables do
      after(:create) do |vocabulary, evaluator|
        create_list(:meta_key_vocables, 1, vocabulary: vocabulary)
      end
    end
  end

end
