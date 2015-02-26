FactoryGirl.define do

  factory :meta_datum_text, class: MetaDatum::Text do
    value { Faker::Lorem.words.join(' ') }
    meta_key do
      MetaKey.find_by(id: 'test:text') \
               || FactoryGirl.create(:meta_key_text)
    end

    after :build do |mdt|
      unless mdt.media_entry or mdt.collection or mdt.filter_set
        mdt.media_entry = FactoryGirl.create :media_entry
      end
    end

    factory :meta_datum_title do
      meta_key do
        MetaKey.find_by(id: 'madek:core:title') \
          || FactoryGirl.create(:meta_key_text, id: 'madek:core:title')
      end
    end
  end

  factory :meta_datum_keywords, class: MetaDatum::Keywords do
    meta_key do
      MetaKey.find_by(id: 'test:keywords') \
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

  factory :meta_datum_text_date, class: MetaDatum::TextDate do
    value { Faker::Lorem.words.join(' ') }
    meta_key do
      MetaKey.find_by(id: 'test:text') \
        || FactoryGirl.create(:meta_key_text_date)
    end
  end
end
