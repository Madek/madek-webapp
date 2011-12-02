# encoding: utf-8


module FactoryHelper
  def self.rand_bool *opts
    bias = ((opts and opts[0]) or 0.5)
    raise "bias must be a real number within [0,1)" if bias < 0.0 or bias >= 1.0
    (rand < bias) ? true : false
  end
end

FactoryGirl.define do

  factory :media_entry do
    upload_session {FactoryGirl.create :upload_session}
    owner  {User.find_random || (FactoryGirl.create :user)}
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

  factory :grouppermission do
    may_view {FactoryHelper.rand_bool}
    may_download {FactoryHelper.rand_bool}
    may_edit_metadata {FactoryHelper.rand_bool}

    group {Group.find_random || (FactoryGirl.create :group)}
    resource do 
      if FactoryHelper.rand_bool 1.0/3
        Media::Set.find_random ||  (FactoryGirl.create :media_set)
      else
        MediaEntry.find_random || (FactoryGirl.create :media_entry)
      end
    end


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
    email {"#{person.firstname}.#{person.lastname}@example.com".downcase} 
    login {email}
  end

  factory :userpermission do
    may_view {FactoryHelper.rand_bool 1/4.0}
    maynot_view {(not may_view) and FactoryHelper.rand_bool}
    may_download {FactoryHelper.rand_bool 1/4.0}
    maynot_download {(not may_download) and FactoryHelper.rand_bool}
    may_edit_metadata {FactoryHelper.rand_bool 1/4.0}
    maynot_edit_metadata {(not may_edit_metadata) and FactoryHelper.rand_bool}
    user {User.find_random || (FactoryGirl.create :user)} 
    resource do 
      if FactoryHelper.rand_bool 1.0/3
        Media::Set.find_random ||  (FactoryGirl.create :media_set)
      else
        MediaEntry.find_random || (FactoryGirl.create :media_entry)
      end
    end
  end

end
