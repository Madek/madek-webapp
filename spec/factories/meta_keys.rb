FactoryGirl.define do

  factory :meta_key do

    vocabulary do
      vocabulary_id = id.split(':').first
      Vocabulary.find_by(id: vocabulary_id) \
        || FactoryGirl.create(:vocabulary, id: vocabulary_id)
    end

    factory :meta_key_text, class: MetaKey do
      id 'test:string'
      meta_datum_object_type 'MetaDatum::Text'
    end

    factory :meta_key_title, class: MetaKey do
      id 'test:title'
      meta_datum_object_type 'MetaDatum::Text'
    end

    factory :meta_key_keywords, class: MetaKey do
      id 'test:keywords'
      meta_datum_object_type 'MetaDatum::Keywords'
    end

    factory :meta_key_people, class: MetaKey do
      id 'test:people'
      meta_datum_object_type 'MetaDatum::People'
    end

    factory :meta_key_users, class: MetaKey do
      id 'test:users'
      meta_datum_object_type 'MetaDatum::Users'
    end

  end

  factory :meta_key_core, class: MetaKey do

    vocabulary do
      Vocabulary.find_by(id: 'madek_core') \
        ||  FactoryGirl.create(:vocabulary, id: 'madek_core')
    end

    factory :meta_key_core_description, class: MetaKey do
      id 'madek_core:description'
      meta_datum_object_type 'MetaDatum::Text'
    end

    factory :meta_key_core_keywords, class: MetaKey do
      id 'madek_core:keywords'
      meta_datum_object_type 'MetaDatum::Keywords'
    end

    factory :meta_key_core_title, class: MetaKey do
      id 'madek_core:title'
      meta_datum_object_type 'MetaDatum::Text'
    end

  end

end
