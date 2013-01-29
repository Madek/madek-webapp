FactoryGirl.define do

  factory :meta_department do
    name {Faker::Name.last_name}
  end

end


