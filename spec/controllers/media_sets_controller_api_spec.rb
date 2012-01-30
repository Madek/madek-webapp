require 'spec_helper'

describe MediaSetsController do

  before :all do
    @user = FactoryGirl.create :user
    @media_set = FactoryGirl.create :media_set, :user => @user
  end


  it "should respond js" do

    get :index, { :id => @media_set.id, :format => 'json'}, {:user_id => @user.id}
    binding.pry
    response.should  be_success

  end


end

