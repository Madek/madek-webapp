require 'spec_helper'

describe MediaResourceArcsController do
  render_views

  before :all do
    @user = FactoryGirl.create :user
    @parent_set = FactoryGirl.create :media_set, user: @user
    @child1 = FactoryGirl.create :media_set, user: @user
    @child2 = FactoryGirl.create :media_set, user: @user
    @parent_set.children << [@child1,@child2]
  end

  def valid_session
    {user_id: @user.id}
  end

  describe "Getting the arcs by parent_id"  do

    def get_arcs_by_parent_id
      get :get_arcs_by_parent_id, {parent_id: @parent_set.id, format: 'json'}, valid_session
    end

    it "should succedd" do
      get_arcs_by_parent_id
      response.should be_success
    end

    it "should assign @arcs" do
       get_arcs_by_parent_id
       assigns(:arcs).should_not be_nil
    end

    it "should put children into the @arcs" do
       get_arcs_by_parent_id
       assigns(:arcs).map(&:child_id).should include @child1.id
       assigns(:arcs).map(&:child_id).should include @child2.id
    end

    describe "The response" do

      it "should include two children" do
        get_arcs_by_parent_id
        data = JSON.parse(response.body)
        data.size.should == 2
      end

    end 

  end


  describe "Getting one arc " do

    def get_arc
      get :get_arc, {parent_id: @parent_set.id, child_id: @child1.id, format: 'json'}, valid_session
    end

    it "should succedd" do
      get_arc
      response.should be_success
    end

    it "should assign @arc" do
      get_arc
      assigns(:arcs).should_not be_nil
    end

    describe "the assinged @arc " do

      it "should have been set with the parend_id " do 
        get_arc
        assigns(:arcs).parent_id.should == @parent_set.id
      end

      it "should have been set with the child_id" do 
        get_arc
        assigns(:arcs).child_id.should == @child1.id
      end

    end

  end
  
end
