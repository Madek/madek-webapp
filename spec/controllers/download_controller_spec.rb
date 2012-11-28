require 'spec_helper'

describe DownloadController do

  describe "download" do
    before :all do
      FactoryGirl.create :usage_term
      @user = FactoryGirl.create :user
      @me = FactoryGirl.create :media_entry, user: @user
    end
  
    let :valid_session do
      {user_id: @user.id}
    end

    describe "original" do
      it "no more options" do
        get :download, {id: @me.id}, valid_session
      end
      it "size x_large" do
        get :download, {id: @me.id, size: 'x_large'}, valid_session
      end
    end

    describe "naked" do
      it "no more options" do
        get :download, {id: @me.id, nadek: '1'}, valid_session
      end
      it "size x_large" do
        get :download, {id: @me.id, nadek: '1', size: 'x_large'}, valid_session
      end
    end

    describe "update" do
      before :all do
        FactoryGirl.create :meta_context, name: 'io_interface', is_user_interface: false
      end
      it "no more options" do
        get :download, {id: @me.id, update: '1'}, valid_session
      end
      it "size x_large" do
        get :download, {id: @me.id, update: '1', size: 'x_large'}, valid_session
      end
    end

    describe "export" do
      it "xml" do
        get :download, {id: @me.id, type: 'xml'}, valid_session
      end
      it "tms" do
        FactoryGirl.create :meta_context, name: 'tms', is_user_interface: false
        get :download, {id: @me.id, type: 'tms'}, valid_session
      end
    end

    after :each do
      response.should be_success
      response.header.has_key?("Content-Disposition").should be_true
    end    
  end

end
