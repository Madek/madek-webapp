require 'spec_helper'

describe MediaResourceArcsController do
  include Controllers::Shared
  render_views

  before :each do
    FactoryGirl.create :usage_term
    @user = FactoryGirl.create :user
    @parent_set = FactoryGirl.create :media_set, user: @user
    @child1 = FactoryGirl.create :media_entry, user: @user
    @child2 = FactoryGirl.create :media_entry, user: @user
    @parent_set.child_media_resources << [@child1,@child2]
  end


  describe "Getting the arcs by parent_id"  do
  
    before :each do
      get :index, {parent_id: @parent_set.id, format: 'json'}, valid_session(@user)
      @data = JSON.parse(response.body)["media_resource_arcs"]
    end

    it "should succeed" do
      expect(response).to be_success
    end

    it "should return non empty json" do
       expect(@data).not_to be_nil
       expect(@data).not_to be_empty
    end

    it "should put children into the response" do
      expect(@data.map{|x| x["child_id"] }).to include @child1.id
      expect(@data.map{|x| x["child_id"] }).to include @child2.id
    end

    describe "The response" do
      it "should include two children" do
        expect(MediaResourceArc.where(parent_id: @parent_set.id).count).to be== 2
        expect(@data.size).to be== 2
      end
    end 

  end


  describe "Updating arcs via PUT " do

    it "should updated the highlight parameter to true" do
      arcs = [{ parent_id: @parent_set.id, child_id: @child1.id, highlight: true}]
      put :update_arcs, {media_resource_arcs: arcs, format: 'json'}, valid_session(@user)
      expect(response).to be_success
      expect(
        MediaResourceArc.where(parent_id: @parent_set.id, child_id: @child1.id).first.highlight
      ).to be true
    end

    it "should updated the cover parameter to true and be always unique" do
      arcs = [{ parent_id: @parent_set.id, child_id: @child1.id, cover: true}]
      put :update_arcs, {media_resource_arcs: arcs, format: 'json'}, valid_session(@user)
      expect(response).to be_success
      expect(MediaResourceArc.where(parent_id: @parent_set.id).count).to be== 2
      expect(
        MediaResourceArc.where(parent_id: @parent_set.id, child_id: @child1.id).first.cover
      ).to be true

      arcs = [{ parent_id: @parent_set.id, child_id: @child1.id, cover: false}, { parent_id: @parent_set.id, child_id: @child2.id, cover: true}]
      put :update_arcs, {media_resource_arcs: arcs, format: 'json'}, valid_session(@user)
      expect(response).to be_success
      expect(MediaResourceArc.where(parent_id: @parent_set.id).count).to be== 2
      expect(
        MediaResourceArc.where(parent_id: @parent_set.id, child_id: @child1.id).first.cover
      ).to be false
      expect(
        MediaResourceArc.where(parent_id: @parent_set.id, child_id: @child2.id).first.cover
      ).to be true
    end

  end
  
end
