FactoryGirl.define do

  factory :meta_datum_person do
    meta_key {MetaKey.find_by_id 5} # the author
  end

end


