FactoryGirl.define do

  factory :user do |n|
    person { FactoryGirl.create :person }
    email do
      Faker::Internet.email.gsub('@',
                                 '_' + SecureRandom.uuid.first(8) + '@')
    end
    login { Faker::Internet.user_name + (SecureRandom.uuid.first 8) }
    usage_terms_accepted_at { Time.now }
    password { SecureRandom.uuid }
  end

  factory :admin_user, class: User do |n|
    person { FactoryGirl.create :person }
    email do
      Faker::Internet.email.gsub('@',
                                 '_' + SecureRandom.uuid.first(8) + '@')
    end
    login { Faker::Internet.user_name + (SecureRandom.uuid.first 8) }
    usage_terms_accepted_at { Time.now }
    password { SecureRandom.uuid }
    admin { FactoryGirl.create :admin }
  end

end
