FactoryGirl.define do

  factory :meta_datum_keywords do
    meta_key {MetaKey.find_by_label "keywords"} 
  end

end


