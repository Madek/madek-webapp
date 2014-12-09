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

    before :example do
      @user = FactoryGirl.create :user
      @media_entry = FactoryGirl.create :media_entry, responsible_user: @user
    end

    it "show" do
      get :show, { id: @media_entry.id }
      assert_template :show
      expect(assigns(:media_entry).id).to eq @media_entry.id
      assert_response :success
    end

  end

end
