require 'spec_helper'
require 'pry'

describe MediaSetsController do

  before :all do
    DevelopmentHelpers::MetaDataPreset.load_minimal_yaml
    @user = FactoryGirl.create :user
    @media_set = FactoryGirl.create :media_set, :user => @user
  end

  describe "GET nested sets index in HTML format" do
    it "should respond with success" do
      get :index, {:media_set_id => @media_set.id}, {:user_id => @user.id}
      response.should  be_success
    end
  end

  describe "GET inheritable_contexts in JSON format" do

    it "should respond with success" do
      get :inheritable_contexts,{ :id => @media_set.id, :format => 'json'}, {:user_id => @user.id}
      response.should  be_success
    end

    it "assigns inheritable_contexts" do
      get :inheritable_contexts,{ :id => @media_set.id, :format => 'json'}, {:user_id => @user.id}
      assigns(:inheritable_contexts).should == []
    end


    context "with inherited context" do

      before :all do
        @media_set.parent_sets << (@parent1 = FactoryGirl.create :media_set)
        @parent1.individual_contexts << (@meta_context11 = FactoryGirl.create :meta_context)
      end

      it "should respond with success" do
        get :inheritable_contexts,{ :id => @media_set.id, :format => 'json'}, {:user_id => @user.id}
        response.should  be_success
      end

      it "should contain the inherited context " do
        get :inheritable_contexts,{ :id => @media_set.id, :format => 'json'}, {:user_id => @user.id}
        assigns(:inheritable_contexts).should include{@meta_context11}
      end
    end
  end
end
