# encoding: utf-8


module DataFactory 
  extend self

  def clear_data 
    ActiveRecord::Base.transaction do
      MediaEntry.all.each {|e| e.destroy}
      MediaSet.all.each {|e| e.destroy}
      MediaResource.all.each {|e| e.destroy}
      Grouppermission.all.each {|e| e.destroy}
      Userpermission.all.each {|e| e.destroy}
      User.all.each {|e| e.destroy}
    end
  end

  def create_permission_migration_dataset
    ActiveRecord::Base.transaction do
      (1..50).each {FactoryGirl.create :user}
      (1..50).each {FactoryGirl.create :media_entry}
      (1..50).each {FactoryGirl.create :media_set}
      (1..10).each {FactoryGirl.create :permission}
    end
  end

  def create_small_dataset 
    ActiveRecord::Base.transaction do
      (1..10).each {FactoryGirl.create :user}
      (1..50).each {FactoryGirl.create :media_entry}
      (1..50).each {FactoryGirl.create :media_set}
      (1..25).each do 
        mr = MediaResource.find_random
        u =  MediaResource.find_random
        unless Userpermission.where(user: u).where(media_resource: mr)
          FactoryGirl.create(:userpermission, user: u, media_resource: mr ) 
        end
      end
    end
  end

end


module FactoryHelper

  def self.rand_bool *opts
    bias = ((opts and opts[0]) or 0.5)
    raise "bias must be a real number within [0,1)" if bias < 0.0 or bias >= 1.0
    (rand < bias) ? true : false
  end

end

FactoryGirl.define do

  ### Meta

  factory :meta_context do
    name {Faker::Lorem.words.join("_")}
    is_user_interface true
  end

  ### Media ....

  factory :media_set_arc , :class => MediaSetArc do
  end

  factory :media_entry do
    upload_session {FactoryGirl.create :upload_session}
    user {upload_session.user}
    media_file {FactoryGirl.create :media_file}

    view {FactoryHelper.rand_bool 1/10.0}
    download { view and FactoryHelper.rand_bool}
    edit {FactoryHelper.rand_bool 1/10.0}
    manage {edit and FactoryHelper.rand_bool}

    after_build do |me|
      def me.extract_subjective_metadata; end
      def me.set_copyright; end
      def me.set_descr_author_value record; end
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

  factory :media_resource do
    user {User.find_random || (FactoryGirl.create :user)}

    view {FactoryHelper.rand_bool 1/10.0}
    download { view and FactoryHelper.rand_bool}
    edit {FactoryHelper.rand_bool 1/10.0}
    manage {edit and FactoryHelper.rand_bool}
  end

  factory :media_set do

    user {User.find_random || (FactoryGirl.create :user)}

    view {FactoryHelper.rand_bool 1/10.0}
    download { view and FactoryHelper.rand_bool}
    edit {FactoryHelper.rand_bool 1/10.0}
    manage {edit and FactoryHelper.rand_bool}

  end

  ### Permissions ...


  factory :permission do
    subject {FactoryHelper.rand_bool ? User.find_random : Group.find_random }
    media_resource { MediaResource.find_random }
    after_build do |perm| 
      permissions = {:view => FactoryHelper.rand_bool, :edit => FactoryHelper.rand_bool, :manage => FactoryHelper.rand_bool, :hi_res => FactoryHelper.rand_bool}
      perm.set_actions permissions 
    end
  end
 



  factory :userpermission do
    view {FactoryHelper.rand_bool 1/4.0}
    download { view and FactoryHelper.rand_bool}
    edit {FactoryHelper.rand_bool 1/4.0}
    manage {edit and FactoryHelper.rand_bool}
    user {User.find_random || (FactoryGirl.create :user)} 

    media_resource do 
      MediaResource.find_random || 
        begin
          if FactoryHelper.rand_bool 1.0/3
            FactoryGirl.create :media_set
          else
            FactoryGirl.create :media_entry
          end
        end
    end

  end


  factory :grouppermission do

    view {FactoryHelper.rand_bool 1/4.0}
    download { view and FactoryHelper.rand_bool}
    edit {FactoryHelper.rand_bool 1/4.0}
    manage {edit and FactoryHelper.rand_bool}

    group {Group.find_random || (FactoryGirl.create :group)}

    media_resource do 
      if FactoryHelper.rand_bool 1.0/3
        FactoryGirl.create :media_set
      else
        FactoryGirl.create :media_entry
      end
    end

  end



  ### Groups, Users, ....

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

  factory :user do |n| 
    person {FactoryGirl.create :person}
    email {Faker::Internet.email}
    login {Faker::Internet.user_name + "_#{UUIDTools::UUID.random_create.to_s.first 5}"}
    usage_terms_accepted_at {Time.now}
  end

  factory :media_sets_userpermissions_join do
  end

  factory :media_entries_userpermissions_join do
  end

end
