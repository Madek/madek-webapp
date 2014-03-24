require 'spec_helper'

describe "authentication"  do
  describe "on get /api/media_resources as an example" do

    before :all do
      @user1 = FactoryGirl.create :user, login: "user1"
      @api_app1= API::Application.create!( user: @user1, id: 'app1').reload
    end
    after :all do
      truncate_tables
    end

    context "with no headers at all" do

      it "responds with 404 Not Authorized " do
        get "/api/media_resources"
        response.status.should be== 401
      end

    end
    context "with a valid HTTP Basic header" do

      let :valid_header_value do
        %[Basic #{::Base64.strict_encode64("#{@api_app1.id}:#{@api_app1.secret}")}]
      end

      it "responds with success" do
        get "/api/media_resources", {}, "AUTHORIZATION" => valid_header_value
        response.should be_success
      end

    end

  end
end

