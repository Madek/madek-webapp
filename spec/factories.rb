# encoding: utf-8

FactoryGirl.define do

  factory :media_entry do
    upload_session {FactoryGirl.create :upload_session}
    media_file {FactoryGirl.create :media_file}
    after_build do |me|
      def me.extract_subjective_metadata; end
      def me.set_copyright; end
      def me.set_descr_author_value; end
    end
  end

  factory :media_file  do 
    uploaded_data  {{ :type=> "image/png", :tempfile=> File.new("#{Rails.root}/app/assets/images/icons/eye.png", "r"), :filename=> "eye.png"}} 
    content_type "image/png"
    guid  (Digest::SHA1.hexdigest Time.now.to_f.to_s)
    filename  "dummy.png"
    access_hash  UUIDTools::UUID.random_create.to_s
    after_build do |mf|
      def mf.assign_access_hash; end
      def mf.validate_file; end
      def mf.store_file; end
    end
  end

  factory :media_set, :class => Media::Set do
    user {User.find_random || (FactoryGirl.create :user)}
    owner {User.find_random || (FactoryGirl.create :user)}
  end

  factory :group do
    name {Faker::Name.last_name}
  end

  factory :person do
    lastname {Faker::Name.last_name}
    firstname {Faker::Name.first_name}
  end

  factory :upload_session do
    user {User.find_random || (FactoryGirl.create :user)}
    is_complete true
  end

  factory :user do
    person {FactoryGirl.create :person}
    email {UUIDTools::UUID.random_create.hexdigest.slice(0,20)+"@example.com"}
    login {email}
  end

end
