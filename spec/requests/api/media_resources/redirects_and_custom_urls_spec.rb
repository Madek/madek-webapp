require 'spec_helper'

describe "custom urls and redirection for /media_resources/:id, /media_entries/:id, etc" do

  before :all do
    @user1 = FactoryGirl.create :user, login: "user1"

    @api_app1= API::Application.create!(user: @user1, id: 'app1').reload

    @media_entry= FactoryGirl.create :media_entry_with_image_media_file, view: true, download: true

    @custom_url= CustomUrl.create! \
      media_resource: @media_entry, id: "the_custom_url",
      creator: @user1, updator: @user1
  end

  after :all do
    truncate_tables
  end

  let :valid_authorization do
    { "AUTHORIZATION" => @api_app1.authorization_header_value }
  end

  describe "get /api/media_resources/:media_entry_id " do
    before :each do
      get "/api/media_resources/#{@media_entry.id}" , {} , valid_authorization
    end
    it "returns a redirect to /api/media_entries/:id" do
      response.status.should be== 302
      response.headers['Location'].should match /\/api\/media_entries\/#{@media_entry.id}/
    end
  end

  describe "requesting a custom url" do

    describe "get /api/media_resources/the_custom_url" do
      before :each do
        get "/api/media_resources/#{@custom_url.id}" , {} , valid_authorization
      end
      it "returns a redirect to /api/media_resources/:id" do
        response.status.should be== 302
        response.headers['Location'].should match /\/api\/media_resources\/#{@media_entry.id}/
      end
    end


    describe "get /api/media_entries/the_custom_url" do
      before :each do
        get "/api/media_entries/#{@custom_url.id}" , {} , valid_authorization
      end
      it "returns a redirect to /api/media_resources/the_custom_url" do
        response.status.should be== 302
        response.headers['Location'].should match /\/api\/media_resources\/#{@custom_url.id}/
      end
    end

  end

end
