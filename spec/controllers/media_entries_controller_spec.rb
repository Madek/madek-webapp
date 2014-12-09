require 'spec_helper'

describe MediaEntriesController do

  context "multiple media entries" do

    it "index" do
      get :index
      assert_template :index
      assigns(:media_entries)
      assert_response :success
    end

  end

  context "one media entry" do

    before :context do
      @user = FactoryGirl.create :user
      @media_entry = FactoryGirl.create :media_entry, responsible_user: @user
    end

    it "show" do
      get :show, { id: @media_entry.id }
      assert_template :show
      expect(assigns(:media_entry).id).to eq @media_entry.id
      assert_response :success
    end

    it "new" do
      get :new
      assert_template :new
      assigns :media_entry
      assert_response :success
    end

    context "create" do

      it "creates successfully" do
        post :create, { responsible_user_id: @user.id, title: "test" }
        media_entry = assigns(:media_entry)
        assert_redirected_to media_entry_path(media_entry)
        expect(flash[:notice]).not_to be_nil
      end

      it "validates and does not persist" do
        post :create, { responsible_user_id: @user.id }
        media_entry = assigns(:media_entry)
        assert_response :success
        assert_template :new
        expect(flash[:error]).not_to be_nil
        expect(media_entry).not_to be_persisted
      end

    end

    context "update" do

      before :example do
        @user2 = FactoryGirl.create :user
      end

      it "updates successfully" do
        put :update, { id: @media_entry.id, responsible_user_id: @user2.id }
        media_entry = assigns(:media_entry)
        assert_redirected_to media_entry_path(media_entry)
        expect(flash[:notice]).not_to be_nil
      end

      it "validates and does not persist" do
        put :update, { id: @media_entry.id, responsible_user_id: nil }
        media_entry = assigns(:media_entry)
        assert_response :success
        assert_template :edit
        expect(flash[:error]).not_to be_nil
        expect(media_entry).not_to be_valid
      end

    end

    it "destroy" do
      delete :destroy, { id: @media_entry.id }, { user_id: @user.id }
      media_entry = assigns(:media_entry)
      assert_redirected_to my_dashboard_path(@user.id)
      expect(flash[:notice]).not_to be_nil
    end

  end

end
