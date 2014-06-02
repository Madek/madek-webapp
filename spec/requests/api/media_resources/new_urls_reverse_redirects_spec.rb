require 'spec_helper'

describe "redirects for /api/entries/:id and /api/sets/:id to /api/media_resources/:id " do

  before :all do
    @user1 = FactoryGirl.create :user, login: "user1"

    @api_app1= API::Application.create!(user: @user1, id: 'app1').reload

    @media_entry= FactoryGirl.create :media_entry_with_image_media_file, view: true, download: true
    @media_set= FactoryGirl.create :media_set, view: true, download: true

  end

  after :all do
    truncate_tables
  end

  let :valid_authorization do
    { "AUTHORIZATION" => @api_app1.authorization_header_value }
  end

  describe "get /api/entries/:media_entry_id " do
    before :each do
      get "/api/entries/#{@media_entry.id}" , {} , valid_authorization
    end
    it "returns a redirect to /api/media_resources/:id" do
      response.status.should be== 301
      response.headers['Location'].should match /\/api\/media_resources\/#{@media_entry.id}/
    end
  end

  describe "get /api/sets/:media_set_id " do
    before :each do
      get "/api/sets/#{@media_set.id}" , {} , valid_authorization
    end
    it "returns a redirect to /api/media_resources/:id" do
      response.status.should be== 301
      response.headers['Location'].should match /\/api\/media_resources\/#{@media_set.id}/
    end
  end



end
