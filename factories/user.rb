FactoryGirl.define do

  factory :user do |n| 
    person {FactoryGirl.create :person}
    email {Faker::Internet.email.gsub("@","_"+SecureRandom.uuid.first(8)+"@")}
    login {Faker::Internet.user_name + (SecureRandom.uuid.first 8) }
    usage_terms_accepted_at {Time.now}
  end

end
