require 'spec_helper'
require 'pry'

describe MediaSetsController do

  before :each do
    @user = FactoryGirl.create :user
    @media_set = FactoryGirl.create :media_project, :user => @user
  end

  describe "GET inheritable_contexts" do

    it "assigns inheritable_contexts" do
      get :inheritable_contexts,{ :id => @media_set.id}, {:user_id => @user.id}
      assigns(:inheritable_contexts).should == []
    end

    context "with iherited context" do

      before :each do
        @media_set.parent_sets << (@parent1 = FactoryGirl.create :media_project)
        @parent1.individual_contexts << (@meta_context11 = FactoryGirl.create :meta_context)
      end

      it "should contain the inherited context " do
        get :inheritable_contexts,{ :id => @media_set.id}, {:user_id => @user.id}
        assigns(:inheritable_contexts).should include{@meta_context11}
      end

    end

  end


end
