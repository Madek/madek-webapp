require 'spec_helper'

describe MetaDataController do
  render_views


  before :each do
    @user = FactoryGirl.create :user
    @media_resource= FactoryGirl.create :media_set
    @media_resource.meta_data.create(:meta_key => MetaKey.find_by_label("title"), :value => Faker::Lorem.words(4).join(' '))
  end

  let :session do
    {:user_id => @user.id}
  end


  describe "as JSON" do
    it "" do
      get :index, {format: 'json', media_set_id: @media_resource.id}, session
      response.should  be_success
      json = JSON.parse(response.body)

      json.detect{|e| e["key"] == "title"}.should be
      json.detect{|e| e["key"] == "title"}["type"].should == "String"

      json.detect{|e| e["key"] == "owner"}.should be
      json.detect{|e| e["key"] == "owner"}["type"].should == "User"
    end

  end

end
