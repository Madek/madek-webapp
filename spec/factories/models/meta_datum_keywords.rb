FactoryGirl.define do

  factory :meta_datum_keywords do
    meta_key {MetaKey.find_by_label "keywords"} 
    media_resource {FactoryGirl.create :media_resource}
  end

end


