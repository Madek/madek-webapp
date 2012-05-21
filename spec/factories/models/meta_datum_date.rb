FactoryGirl.define do

  factory :meta_datum_date do
    meta_key {MetaKey.find_by_id 8}
    meta_date_from {FactoryGirl.create :meta_date}
    meta_date_to {FactoryGirl.create :meta_date}
  end

end


