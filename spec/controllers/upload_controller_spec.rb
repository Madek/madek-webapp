require 'spec_helper'

describe UploadController do

  before :all do
    DevelopmentHelpers::MetaDataPreset.load_minimal_yaml
    @user = FactoryGirl.create :user
  end

  describe "request delete" do

    describe "canceling the import process" do
      it "should respond with error to delete with json request" do
        delete :destroy, {format: 'json'}, {user_id: @user.id}
        response.should_not  be_success
      end

      it "should redirect to root on delete with html request" do
        delete :destroy, {}, {user_id: @user.id}
        response.should  redirect_to(root_path)
      end
    end

    describe "a single media_entry_incomplete with json format" do
      before :all do
        @mei = FactoryGirl.create :media_entry_incomplete, user: @user
      end

      it "should delete and respond with success" do
        @user.incomplete_media_entries.count.should == 1
        delete :destroy, {format: 'json', media_entry_incomplete: {id: @mei.id}}, {user_id: @user.id}
        @user.incomplete_media_entries.count.should == 0
        MediaEntryIncomplete.exists?(@mei.id).should == false
        response.should  be_success
      end
    end

    describe "a single dropbox file with json format" do
      # pending  
    end
    
  end

end
