FactoryGirl.define do
  factory :keyword_term do
    term { Faker::Lorem.words.join(' ') }
    meta_key do
      MetaKey.find_by(id: 'test:keywords') \
               ||  FactoryGirl.create(:meta_key_keywords)
    end
  end
end
