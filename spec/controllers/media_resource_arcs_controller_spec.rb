require 'spec_helper'

describe MediaResourceArcsController do
  render_views

  before :all do
    FactoryGirl.create :usage_term
    @user = FactoryGirl.create :user
    @parent_set = FactoryGirl.create :media_set, user: @user
    @child1 = FactoryGirl.create :media_entry, user: @user
    @child2 = FactoryGirl.create :media_entry, user: @user
    @parent_set.child_media_resources << [@child1,@child2]
  end

  def valid_session
    {user_id: @user.id}
  end

  describe "Getting the arcs by parent_id"  do
  
    before :each do
      get :index, {parent_id: @parent_set.id, format: 'json'}, valid_session
      @data = JSON.parse(response.body)["media_resource_arcs"]
    end

    it "should succeed" do
      response.should be_success
    end

    it "should return non empty json" do
       @data.should_not be_nil
       @data.should_not be_empty
    end

    it "should put children into the response" do
       @data.map{|x| x["child_id"] }.should include @child1.id
       @data.map{|x| x["child_id"] }.should include @child2.id
    end

    describe "The response" do
      it "should include two children" do
        MediaResourceArc.where(parent_id: @parent_set.id).count.should == 2
        @data.size.should == 2
      end
    end 

  end


  describe "Updating arcs via PUT " do

    it "should updated the highlight parameter to true" do
      arcs = [{ parent_id: @parent_set.id, child_id: @child1.id, highlight: true}]
      put :update_arcs, {media_resource_arcs: arcs, format: 'json'}, valid_session
      response.should be_success
      MediaResourceArc.where(parent_id: @parent_set.id, child_id: @child1.id).first.highlight.should be_true
    end

    it "should updated the cover parameter to true and be always unique" do
      arcs = [{ parent_id: @parent_set.id, child_id: @child1.id, cover: true}]
      put :update_arcs, {media_resource_arcs: arcs, format: 'json'}, valid_session
      response.should be_success
      MediaResourceArc.where(parent_id: @parent_set.id).count.should == 2
      MediaResourceArc.where(parent_id: @parent_set.id, child_id: @child1.id).first.cover.should be_true

      arcs = [{ parent_id: @parent_set.id, child_id: @child1.id, cover: false}, { parent_id: @parent_set.id, child_id: @child2.id, cover: true}]
      put :update_arcs, {media_resource_arcs: arcs, format: 'json'}, valid_session
      response.should be_success
      MediaResourceArc.where(parent_id: @parent_set.id).count.should == 2
      MediaResourceArc.where(parent_id: @parent_set.id, child_id: @child1.id).first.cover.should be_false
      MediaResourceArc.where(parent_id: @parent_set.id, child_id: @child2.id).first.cover.should be_true
    end

  end
  
end
