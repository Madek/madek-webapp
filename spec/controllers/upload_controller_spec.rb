require 'spec_helper'

describe UploadController do

  before :all do
    @user = FactoryGirl.create :user
  end


  it "should respond with error to delete with non json request" do
    delete :destroy, {}, {user_id: @user.id}
    response.should_not  be_success
  end

  describe "request delete with json" do
    before :each do
      FactoryGirl.create :media_entry_incomplete, user: @user
    end

    it "should respond with success" do
      delete :destroy, {format: 'json'}, {user_id: @user.id}
      response.should  be_success
    end

    it "should have deleted the incomplete media_entry instance" do
      @user.incomplete_media_entries.count.should == 1
      delete :destroy, {format: 'json'}, {user_id: @user.id}
      @user.incomplete_media_entries.count.should == 0
    end
  end

end
