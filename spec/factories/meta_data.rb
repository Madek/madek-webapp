FactoryGirl.define do

  factory :meta_datum_text, class: MetaDatum::Text do
    value { Faker::Lorem.words.join(' ') }
    meta_key { MetaKey.find_by_id('text') || FactoryGirl.create(:meta_key_text) }
    media_entry { FactoryGirl.create :media_entry }
  end

  factory :meta_datum_people, class: MetaDatum::People do
    people { (1..3).map { FactoryGirl.create :person } }
  end

end
