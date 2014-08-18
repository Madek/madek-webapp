require 'spec_helper'

describe DownloadController do
  include Controllers::Shared

  describe "download" do
    before :each do
      FactoryGirl.create :usage_term
      @user = FactoryGirl.create :user
      @me = FactoryGirl.create :media_entry_with_image_media_file, user: @user
    end
  
    describe "original" do
      it "no more options" do
        get :download, {id: @me.id}, valid_session(@user)
      end
      it "size x_large" do
        get :download, {id: @me.id, size: 'x_large'}, valid_session(@user)
      end
    end

    describe "naked" do
      it "no more options" do
        get :download, {id: @me.id, nadek: '1'}, valid_session(@user)
      end
      it "size x_large" do
        get :download, {id: @me.id, nadek: '1', size: 'x_large'}, valid_session(@user)
      end
    end

    describe "update" do
      before :each do
        FactoryGirl.create :io_interface
      end

      it "no more options" do
        get :download, {id: @me.id, update: '1'}, valid_session(@user)
      end
      it "size x_large" do
        get :download, {id: @me.id, update: '1', size: 'x_large'}, valid_session(@user)
      end
    end

    describe "export" do
      it "xml" do
        get :download, {id: @me.id, type: 'xml'}, valid_session(@user)
      end
      it "tms" do
        FactoryGirl.create :io_interface, id: 'tms'
        get :download, {id: @me.id, type: 'tms'}, valid_session(@user)
      end
    end

    after :each do
      response.should be_success
      response.header.has_key?("Content-Disposition").should be_true
    end    
  end

end
