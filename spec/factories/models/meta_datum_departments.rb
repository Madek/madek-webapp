FactoryGirl.define do

  factory :meta_datum_departments do
    meta_key {MetaKey.find_by_label "institutional affiliation"} 
  end

end


