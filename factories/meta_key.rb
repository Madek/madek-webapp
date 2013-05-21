FactoryGirl.define do

  factory :meta_key do
    id { Faker::Lorem.words.join("_") }
    meta_datum_object_type "MetaDatumString" 
  end

  factory :meta_key_title, class: MetaKey do
    id 'title'
    meta_datum_object_type "MetaDatumString" 
  end

  factory :meta_key_copyright_status, class: MetaKey do
    id 'copyright status'
    meta_datum_object_type "MetaDatumCopyright" 
  end

  factory :meta_key_copyright_usage, class: MetaKey do
    id 'copyright usage'
    meta_datum_object_type "MetaDatumCopyright" 
  end

  factory :meta_key_copyright_url, class: MetaKey do
    id 'copyright url'
    meta_datum_object_type "MetaDatumCopyright" 
  end

  factory :meta_key_academic_year, class: MetaKey do
    id 'academic year'
    meta_datum_object_type 'MetaDatumMetaTerms'
    is_extensible_list false
  end
  
  factory :meta_key_author, class: MetaKey do
    id 'author'
    meta_datum_object_type 'MetaDatumPeople'
  end

  factory :meta_key_keywords, class: MetaKey do
    id 'keywords'
    meta_datum_object_type 'MetaDatumKeywords'
  end

  factory :meta_key_institutional_affiliation, class: MetaKey do
    id 'institutional affiliation'
    meta_datum_object_type 'MetaDatumDepartments'
  end

  factory :meta_key_public_caption, class: MetaKey do
    id 'public caption'
    meta_datum_object_type 'MetaDatumKeywords'
  end

end
