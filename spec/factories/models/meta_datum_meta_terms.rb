FactoryGirl.define do

  factory :meta_datum_meta_terms do
    meta_key {MetaKey.find_by_label "academic year"} 
    media_resource {FactoryGirl.create :media_resource}
  end

end


