FactoryGirl.define do

  factory :meta_datum_text, class: MetaDatum::Text do
    value { Faker::Lorem.words.join(' ') }
    meta_key do
      MetaKey.find_by_id('test:text') \
               || FactoryGirl.create(:meta_key_text)
    end

    after :build do |mdt|
      unless mdt.media_entry or mdt.collection or mdt.filter_set
        mdt.media_entry = FactoryGirl.create :media_entry
      end
    end
  end

  factory :meta_datum_keywords, class: MetaDatum::Keywords do
    meta_key do
      MetaKey.find_by_id('test:keywords') \
               || FactoryGirl.create(:meta_key_keywords)
    end

    after :build do |mdt|
      unless mdt.media_entry or mdt.collection or mdt.filter_set
        mdt.media_entry = FactoryGirl.create :media_entry
      end
    end
  end

  factory :meta_datum_people, class: MetaDatum::People do
    people { (1..3).map { FactoryGirl.create :person } }
  end

  factory :meta_datum_users, class: MetaDatum::Users do
    users { (1..3).map { FactoryGirl.create :user } }
  end

end
