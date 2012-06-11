FactoryGirl.define do

  factory :meta_datum_date do
    string "2011-01-01"
    meta_key {MetaKey.find_by_label "portrayed object dates"}
    media_resource {FactoryGirl.create :media_resource}
  end

end


