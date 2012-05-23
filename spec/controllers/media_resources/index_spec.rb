require 'spec_helper'

describe MediaResourcesController do
  render_views
  
  before :all do
    @user = FactoryGirl.create :user
  end
  
  context "fetch an index of media resources" do
    before :all do
      # MediaResources
      40.times do
        type = rand > 0.5 ? :media_entry : :media_set
        mr = Factory type, :user => @user
        mr.parents << FactoryGirl.create(:media_set, :user => @user)
        mr.meta_data.create(:meta_key => MetaKey.find_by_label("title"), :value => Faker::Lorem.words(4).join(' '))
      end
      # MetaContext
      @meta_context = MetaContext.first
    end
    
    let :session do
      {:user_id => @user.id}
    end
    
    let :ids do
      MediaResource.all.shuffle[1..3].map(&:id)
    end

    describe "as guest user" do
      it "should respond with success" do
        get :index, {format: 'json'}
        response.should  be_success
        json = JSON.parse(response.body)
        json.keys.sort.should == ["media_resources", "pagination"]
        json["pagination"].keys.sort.should == ["page", "per_page", "total", "total_pages"]
        json["media_resources"].is_a?(Array).should be_true
        json["media_resources"].size.should <= json["pagination"]["per_page"]
        n = MediaResource.accessible_by_user(User.new).count
        json["pagination"]["total"].should == n
      end
    end
    
    describe "as logged in user" do
      it "should respond with success" do
        get :index, {format: 'json'}, session
        response.should  be_success
        json = JSON.parse(response.body)
        json.keys.sort.should == ["media_resources", "pagination"]
        json["pagination"].keys.sort.should == ["page", "per_page", "total", "total_pages"]
        json["media_resources"].is_a?(Array).should be_true
        json["media_resources"].size.should <= json["pagination"]["per_page"]
        n = MediaResource.accessible_by_user(@user).count
        json["pagination"]["total"].should == n
      end
      end
    
    describe "a plain response" do
      it "should respond only with a collection of id's and type's if there is not more requested" do
        get :index, {format: 'json', ids: ids}, session
        response.should be_success
        json = JSON.parse(response.body)
        json["media_resources"].each do |mr|
          mr.keys.size.should == 2
          mr.keys.include?("id").should be_true
          mr.keys.include?("type").should be_true
        end     
      end
    end
    
    describe "a response with images" do
      it "respond with a collection of resources with images as base 64 when requested" do
       get :index, {format: 'json', ids: ids, with: {image: {as: "base64"}}}, session
        response.should be_success
        json = JSON.parse(response.body)
        json["media_resources"].each do |mr|
          mr.keys.should include("image")
        end    
      end
    end

    describe "a response with filename" do
      it "respond with a collection of resources with filename for media_entries when requested" do
       get :index, {format: 'json', ids: ids, with: {filename: true}}, session
        response.should be_success
        json = JSON.parse(response.body)
        json["media_resources"].each do |mr|
          mr.keys.should include("filename")
        end    
      end
    end
    
    describe "a response with parents" do
      it "respond with a collection of resources and their parents" do
       get :index, {format: 'json', ids: ids, with: {parents: true}}, session
        response.should be_success
        json = JSON.parse(response.body)
        json["media_resources"].each do |mr|
          mr.keys.should include("parents")
        end    
      end
    end
    
    describe "a response with nested meta data" do
      
      describe "through meta contexts" do
        it "should respond with a collection of media resources with nested meta data for the core meta context" do
          get :index, {format: 'json', ids: ids, with: {meta_data: {meta_context_names: [@meta_context.name]}}}, session
          response.should  be_success
          json = JSON.parse(response.body)
          json["media_resources"].each do |mr|
            mr["meta_data"].map{|x| x["name"]}.sort.should == @meta_context.meta_keys.map(&:label).sort
          end
        end        
      end
      
      describe "through meta contexts with a collection of provided ids" do
        it "should respond with the requested collection of media resources with nested meta data for the core meta context" do
          get :index, {format: 'json', ids: ids, with: {meta_data: {meta_context_names: [@meta_context.name]}}}, session
          response.should  be_success
          json = JSON.parse(response.body)
          json["media_resources"].each do |mr|
            mr["meta_data"].map{|x| x["name"]}.sort.should == @meta_context.meta_keys.map(&:label).sort
          end
        end        
      end
      
      describe "through meta contexts with a single id provided" do
        it "should respond with the requested collection of media resources with nested meta data for the core meta context" do
          get :index, {format: 'json', ids: ids[0,1], with: {meta_data: {meta_context_names: [@meta_context.name]}}}, session
          response.should  be_success
          json = JSON.parse(response.body)
          json["media_resources"].each do |mr|
            mr["meta_data"].map{|x| x["name"]}.sort.should == @meta_context.meta_keys.map(&:label).sort
          end
        end        
      end
    
      describe "a response filtered by media resource type" do
        it "should respond only with media entries when requested" do
          get :index, {format: 'json', type: "media_entries"}, session
          response.should be_success
          json = JSON.parse(response.body)
          json["media_resources"].each do |mr|
            mr["type"].should == "media_entry"
          end
        end        
        it "should respond only with media sets when requested" do
          get :index, {format: 'json', type: "media_sets"}, session
          response.should be_success
          json = JSON.parse(response.body)
          json["media_resources"].each do |mr|
            mr["type"].should == "media_set"
          end
        end        
      end
    end
  end
end
