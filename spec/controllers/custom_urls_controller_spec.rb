require 'spec_helper'
require 'pry'

describe CustomUrlsController do

  before :each do
    FactoryGirl.create :usage_term 
    FactoryGirl.create :meta_context_core
    @user1 = FactoryGirl.create :user
    @media_set1= FactoryGirl.create :media_set, :user => @user1
    @media_set2= FactoryGirl.create :media_set, :user => @user1
    @user2 = FactoryGirl.create :user
  end

  describe "get index" do

    it "is successful for the owner" do
      get :index, {id: @media_set1.id}, {user_id: @user1.id}
      response.should be_success
    end

    it "raises NotAuthorized if the requester doesn't have view permission" do
      expect {
        get :index, {id: @media_set1.id}, {user_id: @user2.id}
      }.to raise_exception(NotAuthorized)
    end

  end

  context "the user2 has edit permissions, but no manage permission for media_set1" do

    before :each do
      Userpermission.create user: @user2, media_resource: @media_set1, view: true, edit: true, manage: false
    end

    describe "get index" do
      it "is now successful for the user2" do
        get :index, {id: @media_set1.id}, {user_id: @user2.id}
        response.should be_success
      end
    end


    describe "creating a url" do
      it "doesn't create a url" do
        url_c= CustomUrl.count
        post :create, {id: @media_set1.id, url: "the_url"}, {user_id: @user2.id}
        expect(flash[:error]).not_to be_blank
        expect(CustomUrl.count).to be== url_c 
      end
    end


  end

  context "the user2 has manage permission for media_set1" do

    before :each do
      Userpermission.create user: @user2, media_resource: @media_set1, view: true, edit: true, manage: true
    end

    describe "creating a url" do
      it "is successful and creates an url" do
        url_c= CustomUrl.count
        post :create, {id: @media_set1.id, url: "the_url"}, {user_id: @user2.id}
        expect(response.status).to be== 302
        expect(flash[:success]).not_to be_blank
        expect(CustomUrl.count).to be== url_c + 1
      end
    end

    describe "transfering a url from media_set1 to media_set2" do

      before :each do
        @the_url = CustomUrl.create media_resource: @media_set1, id: "the_url", creator: @user1, updator: @user1
      end

      it "posting the transfer doesn't transfer" do
        post :transfer_url, {id: @media_set2.id, url: "the_url"}, {user_id: @user2.id}
        expect(@media_set1.reload.custom_urls).to include @the_url
      end

      context "the user2 has manage permission for media_set2, too" do
        before :each do
          Userpermission.create user: @user2, media_resource: @media_set2, view: true, edit: true, manage: true
        end

        it "posting the transfer does transfer" do
          post :transfer_url, {id: @media_set2.id, url: "the_url"}, {user_id: @user2.id}
          expect(@media_set2.reload.custom_urls).to include @the_url
        end

      end

    end

  end

end
