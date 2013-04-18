require 'spec_helper'

describe FilterSetsController do

  before :each do
    FactoryGirl.create :usage_term 
    FactoryGirl.create :meta_context_core
    @user = FactoryGirl.create :user
  end


  describe "Creating a Filterset " do

    it "should be successful" do
      post :create, {format: 'json', filter_set: {}}, user_id: @user.id
      expect(response).to be_success
    end

    it "should return the newle created  resource" do
      post :create, {format: 'json', filter_set: {}}, user_id: @user.id
      expect(FilterSet.find  (JSON.parse response.body)['id']).to be
    end

  end


  describe "Updating a Filterset" do

    before :each do
      @filter_set = FactoryGirl.create :filter_set, user: @user
    end

    it "should be successful" do
      put :update,  {format: 'json', id: @filter_set.id, filter_set: {}}, user_id: @user.id
      expect(response).to be_success
    end

    it "should update the settings" do
      put :update,  {format: 'json', id: @filter_set.id, filter_set: {settings: {filter: "Blah" }}}, user_id: @user.id
      expect(response).to be_success
      expect(@filter_set.reload.settings['filter']).to eq "Blah"
    end

  end


end
