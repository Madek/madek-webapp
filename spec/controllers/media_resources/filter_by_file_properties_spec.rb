require 'spec_helper'

describe MediaResourcesController do
  render_views

  before :all do
    @user = FactoryGirl.create :user
    #@me_jpg = FactoryGirl.create :media_entry
  end

  let :valid_session do
    {:user_id => @user.id}
  end
  

  describe "basic get request" do

    it "should be successful" do
      get :index, {format: "json"}, valid_session
      expect(response.success?).to be_true
    end

  end


end

