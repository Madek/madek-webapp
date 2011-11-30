# encoding: utf-8


module ModelFactory 

  # some more complicated factories are defined here; e.g. we define methods in
  # the eigenclass, so they shadow the ones from the real class; 
  #
  # unfortunately, this is not as flexible as it would be using FactoryGirl

  def self.create_media_file
    mf = MediaFile.new( :uploaded_data => { :type=> "image/png",
                       :tempfile=> File.new("#{Rails.root}/app/assets/images/icons/eye.png", "r"),
                       :filename=> "eye.png"},
                       :content_type => "image_png",
                       :guid => (Digest::SHA1.hexdigest Time.now.to_f.to_s),
                       :filename => "dummy.png",
                       :access_hash => UUIDTools::UUID.random_create.to_s)
    def mf.assign_access_hash; end
    def mf.validate_file; end
    def mf.store_file; end
    mf.save!
    mf
  end

  def self.create_media_entry 
    me = MediaEntry.new( :upload_session => (FactoryGirl.create :upload_session),
                        :media_file => create_media_file )
    def me.extract_subjective_metadata; end
    def me.set_copyright; end
    def me.set_descr_author_value; end
    me.save!
    me
  end

end

FactoryGirl.define do

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
