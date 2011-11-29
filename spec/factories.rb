FactoryGirl.define do

  factory :media_entry do
    upload_session {FactoryGirl.create :upload_session}
    media_file {FactoryGirl.create :media_file}
  end

  factory :media_file do
    uploaded_data { { :type=> "image/png",
              :tempfile=> File.new("#{Rails.root}/app/assets/images/icons/eye.png", "r"),
              :filename=> "eye.png"} }

  end

  factory :group do
    name {Faker::Name.last_name}
  end

  factory :person do
    lastname {Faker::Name.last_name}
    firstname {Faker::Name.first_name}
  end

  factory :upload_session do
    user {FactoryGirl.create :user}
  end

  factory :user do
    person {FactoryGirl.create :person}
    email {"#{person.firstname}.#{person.lastname}@example.com".downcase} 
    login {email}
  end

  factory :userpermission do
    user {FactoryGirl.create :user}
    resource {FactoryGirl.create :media_entry}
  end


end
