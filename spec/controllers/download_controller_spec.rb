require 'spec_helper'

describe DownloadController do
  include Controllers::Shared

  describe "download as owner" do
    before :each do
      FactoryGirl.create :usage_term
      @user = FactoryGirl.create :user
      @me = FactoryGirl.create :media_entry_with_image_media_file, user: @user
    end

    describe "original" do
      it "original uploaded file" do
        get :download, {id: @me.id}, valid_session(@user)
      end
      it "size x_large" do
        get :download, {id: @me.id, size: 'x_large'}, valid_session(@user)
      end
    end

    describe "naked" do
      it "original uploaded file" do
        get :download, {id: @me.id, nadek: '1'}, valid_session(@user)
      end
      it "size x_large" do
        get :download, {id: @me.id, nadek: '1', size: 'x_large'}, valid_session(@user)
      end
    end

    describe "update" do
      before :each do
        name = :default
        create :io_interface, id: name unless IoInterface.find_by id: name
      end

      it "original uploaded file" do
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
        name = :tms
        create :io_interface, id: name unless IoInterface.find_by id: name
        get :download, {id: @me.id, type: 'tms'}, valid_session(@user)
      end
    end

    after :each do
      expect(response).to be_success
      expect( response.header.has_key?("Content-Disposition") ).to be true
    end
  end

  describe "download as user with view permission" do
    before :each do
      FactoryGirl.create :usage_term
      @user = FactoryGirl.create :user
      @downloader = FactoryGirl.create :user
      @me = FactoryGirl.create :media_entry_with_image_media_file, user: @user
      @me.userpermissions << Userpermission.new(user: @downloader, view: true)
      @me.save!
    end

    describe "original" do
      it "size x_large" do
        get :download, {id: @me.id, size: 'x_large'}, valid_session(@downloader)
      end
    end

    describe "naked" do
      it "size x_large" do
        get :download, {id: @me.id, nadek: '1', size: 'x_large'}, valid_session(@downloader)
      end
    end

    describe "update" do
      before :each do
        name = :default
        create :io_interface, id: name unless IoInterface.find_by id: name
      end

      it "size x_large" do
        get :download, {id: @me.id, update: '1', size: 'x_large'}, valid_session(@downloader)
      end
    end

    after :each do
      expect(response).to be_success
      expect( response.header.has_key?("Content-Disposition") ).to be true
    end
  end

  describe "download not allowed" do
    before :each do
      FactoryGirl.create :usage_term
      @owner = FactoryGirl.create :user
      @me = FactoryGirl.create :media_entry_with_image_media_file, user: @owner
      @downloader = FactoryGirl.create :user
    end

    describe "original uploaded file" do
      it "as public without permissions" do
        get :download, {id: @me.id}
      end
      it "as public with 'view' permission" do
        @me.view = true
        @me.save!
        get :download, {id: @me.id}
      end
      it "as another user without permissions" do
        get :download, {id: @me.id}, valid_session(@downloader)
      end
      it "as another user with 'view' permission" do
        @me.userpermissions << Userpermission.new(user: @downloader, view: true)
        @me.save!
        get :download, {id: @me.id}, valid_session(@downloader)
      end
    end

    describe "export xml" do
      it "as public without permissions" do
        get :download, {id: @me.id, type: 'xml'}
      end
      it "as public with 'view' permission" do
        @me.view = true
        @me.save!
        get :download, {id: @me.id, type: 'xml'}
      end
      it "as another user without permissions" do
        get :download, {id: @me.id, type: 'xml'}, valid_session(@downloader)
      end
      it "as another user with 'view' permission" do
        @me.userpermissions << Userpermission.new(user: @downloader, view: true)
        @me.save!
        get :download, {id: @me.id, type: 'xml'}, valid_session(@downloader)
      end
    end

    describe "export tms" do
      before :each do
        name = :tms
        create :io_interface, id: name unless IoInterface.find_by id: name
      end
      it "as public without permissions" do
        get :download, {id: @me.id, type: 'tms'}
      end
      it "as public with 'view' permission" do
        @me.view = true
        @me.save!
        get :download, {id: @me.id, type: 'tms'}
      end
      it "as another user without permissions" do
        get :download, {id: @me.id, type: 'tms'}, valid_session(@downloader)
      end
      it "as another user with 'view' permission" do
        @me.userpermissions << Userpermission.new(user: @downloader, view: true)
        @me.save!
        get :download, {id: @me.id, type: 'tms'}, valid_session(@downloader)
      end
    end

    after :each do
      expect(response).to redirect_to(root_path)
      expect(flash[:error])
        .to eq('Bitte melden Sie sich an.')
        .or eq('Sie haben nicht die notwendige Zugriffsberechtigung.')
    end
  end

end
