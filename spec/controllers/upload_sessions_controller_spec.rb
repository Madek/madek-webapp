require 'spec_helper'

describe UploadSessionsController do

  before :all do
    @user = FactoryGirl.create :user
    @upload_session  = FactoryGirl.create :upload_session, user: @user
  end


  it "should respond with error to delete with non json request" do
    delete :destroy, {id: @upload_session.id}, {user_id: @user.id}
    response.should_not  be_success
  end

  describe "request delete with json" do
    before :each do
     @us = FactoryGirl.create :upload_session, user: @user 
    end

    it "should respond with success" do
      delete :destroy, {format: 'json', id: @upload_session.id}, {user_id: @user.id}
      response.should  be_success
    end

    it "should have deleted the upload_session instance" do
      delete :destroy, {format: 'json', id: @upload_session.id}, {user_id: @user.id}
      binding.pry
      UploadSession.find(@us.id).should == nil
    end
  end

end
