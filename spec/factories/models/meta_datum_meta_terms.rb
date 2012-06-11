FactoryGirl.define do

  factory :meta_datum_meta_terms do
    meta_key {MetaKey.find_by_label "academic year"} 
  end

end


