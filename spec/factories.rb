# encoding: utf-8

#load Rails.root + "app/models/media_file.rb"
# TODO somehow the orinal model won't get even loaded
# mokey_patch the methods dynamically!
class MediaFile 
  def assign_access_hash; end
  def validate_file; end
  def store_file; end
end


FactoryGirl.define do


  factory :media_entry do
    upload_session {FactoryGirl.create :upload_session}
    media_file {FactoryGirl.create :media_file}
  end

  factory :media_file do


    content_type "image_png"
    guid {Digest::SHA1.hexdigest Time.now.to_f.to_s}
    filename "dummy.png"
    access_hash UUIDTools::UUID.random_create.to_s
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
