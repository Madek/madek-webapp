require 'spec_helper'

describe Admin::MetaKeyDefinitionsController do

  before :all do
    FactoryGirl.create :usage_term 
    @adam = FactoryGirl.create :user, login: "adam"
    Group.find_or_create_by_name("Admin").users << @adam
  end

  def valid_session
    {user_id: @adam.id}
  end

  describe "GET 'index'" do
    it "returns http success" do
      get 'index', {}, valid_session
      response.should be_success
    end
  end

end
