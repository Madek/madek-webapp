require 'spec_helper'

describe "/api/media_resources" do
  
  before :all do
    FactoryGirl.create :meta_context_core
    FactoryGirl.create :meta_key_public_caption
    FactoryGirl.create :meta_key_copyright_status
    FactoryGirl.create :meta_key_copyright_usage
    FactoryGirl.create :meta_key_copyright_url
    @user1 = FactoryGirl.create :user, login: "user1"
    @user2 = FactoryGirl.create :user, login: "user2"
    @api_app1= API::Application.create user: @user1, id: 'app1'
    @api_app2= API::Application.create user: @user2, id: 'app2'

    @media_entry= FactoryGirl.create :media_entry_with_image_media_file

    @application_permission=  API::Applicationpermission.create! \
      media_resource: @media_entry, 
      application: @api_app2,
      view: true,
      download: true
  end

  after :all do
    truncate_tables
  end

  it "doesn't test anything yet" do
    get "/api/media_resources"
  end

end

