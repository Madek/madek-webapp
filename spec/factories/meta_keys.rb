FactoryGirl.define do

  factory :meta_key_text, class: MetaKey do
    id 'test:string'
    meta_datum_object_type 'MetaDatum::Text'
  end

  factory :meta_key_keywords, class: MetaKey do
    id 'test:keywords'
    meta_datum_object_type 'MetaDatum::Keywords'
  end

  factory :meta_key_vocables, class: MetaKey do
    id 'test:vocables'
    meta_datum_object_type 'MetaDatum::Vocables'
  end

end
