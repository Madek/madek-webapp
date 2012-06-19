require 'spec_helper'

describe MediaResourceArcsController do
  render_views

  before :all do
    FactoryGirl.create :usage_term
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
      @data = JSON.parse(response.body)["media_resource_arcs"]
    end

    it "should succeed" do
      get_arcs_by_parent_id
      response.should be_success
    end

    it "should return non empty json" do
       get_arcs_by_parent_id
       @data.should_not be_nil
       @data.should_not be_empty
    end

    it "should put children into the response" do
       get_arcs_by_parent_id
       @data.map{|x| x["child_id"] }.should include @child1.id
       @data.map{|x| x["child_id"] }.should include @child2.id
    end

    describe "The response" do

      it "should include two children" do
        get_arcs_by_parent_id
        @data.size.should == 2
      end

    end 

  end


  describe "Updating arcs via PUT " do

    def update_child1_arc 
      arcs = [{ parent_id: @parent_set.id, child_id: @child1.id, highlight: true}]
      put :update_arcs, {media_resource_arcs: arcs, format: 'json'}, valid_session
    end
    
    it "should succeed" do
      update_child1_arc
      response.should be_success
    end

    it "should updated the highlight parameter to true" do
      update_child1_arc
      MediaResourceArc \
        .where(parent_id: @parent_set.id) \
        .where(child_id: @child1.id) \
        .first.highlight.should be_true
    end

  end
  
end
