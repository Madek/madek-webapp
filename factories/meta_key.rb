FactoryGirl.define do

  factory :meta_key do
    label { Faker::Lorem.words.join("_") }
    meta_datum_object_type "MetaDatumString" 
  end

  factory :meta_key_title, class: MetaKey do
    label 'title'
    meta_datum_object_type "MetaDatumString" 
  end

  factory :meta_key_copyright_status, class: MetaKey do
    label 'copyright status'
    meta_datum_object_type "MetaDatumCopyright" 
  end

  factory :meta_key_academic_year, class: MetaKey do
    label 'academic year'
    meta_datum_object_type 'MetaDatumMetaTerms'
    is_extensible_list false
  end
  
  factory :meta_key_author, class: MetaKey do
    label 'author'
    meta_datum_object_type 'MetaDatumPeople'
  end

  factory :meta_key_keywords, class: MetaKey do
    label 'keywords'
    meta_datum_object_type 'MetaDatumKeywords'
  end

  factory :meta_key_institutional_affiliation, class: MetaKey do
    label 'institutional affiliation'
    meta_datum_object_type 'MetaDatumDepartments'
  end

end
