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

  context "API GET get_arcs_by_parent_id"  do

    def get_arcs_by_parent_id
      get :get_arcs_by_parent_id, {parent_id: @parent_set.id, format: 'json'}, valid_session
    end

    it "should succedd" do
      get_arcs_by_parent_id
      response.should be_success
    end

    it "assigns @arcs" do
       get_arcs_by_parent_id
       assigns(:arcs).should_not be_nil
    end

    it "@arcs should include the children" do
       get_arcs_by_parent_id
       assigns(:arcs).map(&:child_id).should include @child1.id
       assigns(:arcs).map(&:child_id).should include @child2.id
    end

    context "the response" do

      it "should include two children" do
        get_arcs_by_parent_id
        data = JSON.parse(response.body)
        data.size.should == 2
      end

    end 

  end
  
end
