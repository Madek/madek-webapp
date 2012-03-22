FactoryGirl.define do

  factory :meta_context_group do
    sequence :name do |i|
     "#{i}-#{Faker::Name.last_name}"
    end
  end

end
