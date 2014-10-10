require 'spec_helper'

describe MediaResourcesController, type: :controller do
  include Controllers::Shared
  render_views

  # NOTE: This test would be extremely slow with `before :each`.  We use
  # `before :all `before :all` and reset the database in the `after :all` hook.
  # Apparently this comes with the price of some complexity. 

  before :all do
    FactoryGirl.create :usage_term 
    FactoryGirl.create :context_core
    @user = FactoryGirl.create :user

    40.times do
      type = rand > 0.5 ? :media_entry_with_image_media_file : :media_set
      mr = FactoryGirl.create type, :user => @user
      mr.parents << FactoryGirl.create(:media_set, :user => @user)
      mr.meta_data.create(:meta_key => MetaKey.find_by_id("title"), 
                          :value => Faker::Lorem.words(1).join(' '))
    end
    @context = Context.find("core")
  end

  after :all do
    DBHelper.drop
    DBHelper.create
    DBHelper.restore_native Rails.root.join("db","structure.sql")
  end


  describe "fetch an index of media resources" do
  
    let :ids do
      MediaResource.all.shuffle[1..3].map(&:id)
    end

    describe "as guest user" do
      it "should respond with success" do
        get :index, {format: 'json'}
        expect(response).to be_success
        json = JSON.parse(response.body)
        expect(json.keys.sort).to eq ["current_filter", "media_resources", "pagination"]
        expect(json["pagination"].keys.sort).to eq ["page", "per_page", "total", "total_pages"]
        expect(json["media_resources"]).to be_an(Array)
        expect(json["media_resources"].size).to be <= json["pagination"]["per_page"]
        n = MediaResource.accessible_by_user(User.new,:view).count
        expect(json["pagination"]["total"]).to be== n
      end
    end

    describe "as logged in user" do
      it "should respond with success" do
        get :index, {format: 'json'}, valid_session(@user)
        expect(response).to be_success
        json = JSON.parse(response.body)
        expect(json.keys.sort).to eq ["current_filter", "media_resources", "pagination"]
        expect(json["pagination"].keys.sort).to eq ["page", "per_page", "total", "total_pages"]
        expect(json["media_resources"]).to be_an(Array)
        expect(json["media_resources"].size).to be <= json["pagination"]["per_page"]
        n = MediaResource.accessible_by_user(@user,:view).count
        expect(json["pagination"]["total"]).to be== n
      end
    end

    describe "a plain response" do
      it "should respond with a collection containing id's and type's " do
        get :index, {format: 'json', ids: ids}, valid_session(@user)
        expect(response).to be_success
        json = JSON.parse(response.body)
        json["media_resources"].each do |mr|
          expect(mr.keys).to include('id')
          expect(mr.keys).to include('type')
        end     
      end
    end

    describe "a response with images" do
      it "respond with a collection of resources with images as base 64 when requested" do
        get :index, {format: 'json', ids: ids, with: {image: {as: "base64"}}}, valid_session(@user)
        expect(response).to be_success
        json = JSON.parse(response.body)
        json["media_resources"].each do |mr|
          expect(mr.keys).to include("image")
        end    
      end
    end

    describe "a response with filename" do
      it "respond with a collection of resources with filename for media_entries when requested" do
        get :index, {format: 'json', ids: ids, with: {filename: true}}, valid_session(@user)
        expect(response).to be_success
        json = JSON.parse(response.body)
        json["media_resources"].each do |mr|
          expect(mr.keys).to include("filename")
        end    
      end
    end

    describe "a response with parents" do
      it "respond with a collection of resources and their parents" do
        get :index, {format: 'json', ids: ids, with: {parents: true}}, valid_session(@user)
        expect(response).to be_success
        json = JSON.parse(response.body)
        json["media_resources"].each do |mr|
          expect(mr.keys).to include("parents")
        end    
      end

      it "respond with a collection of resources and their parents with pagination" do
        get :index, {format: 'json', ids: ids, with: {parents: true}}, valid_session(@user)
        expect(response).to be_success
        json = JSON.parse(response.body)
        json["media_resources"].each do |mr|
          if mr["type"] == "media_set"
            expect(mr.keys).to include("parents")
            expect(mr["parents"].keys).to include("pagination")
            expect(mr["parents"]["pagination"]["total"]).to be== MediaResource.find(mr["id"]).parents.size
          end
        end 
      end

      it "is paginatable" do
        (2..3).each do |page|
          get :index, {format: 'json', page: page}, valid_session(@user)
          json = JSON.parse(response.body)
          expect(json["pagination"]["page"]).to be== page
        end
      end

      it "has paginatable parents" do
        get :index, {format: 'json', ids: ids, with: {parents: true}}, valid_session(@user)
        json = JSON.parse(response.body)
        mr = json["media_resources"].detect {|mr| mr["type"] == "media_set" }
        media_resource = MediaResource.find mr["id"]
        40.times {
          mr = FactoryGirl.create :media_set, :user => @user
          media_resource.parents << mr
        }

        get :index, {format: 'json', ids: [media_resource.id], with: {parents: true}}, valid_session(@user)
        json = JSON.parse(response.body)
        mr = json["media_resources"].first
        parents_pagination = mr["parents"]["pagination"]
        expect(mr["parents"]["media_resources"].size).to be== parents_pagination["per_page"]
        expect(parents_pagination["total"]).to be >= 40
        expect(parents_pagination["total_pages"]).to be > 1

        get :index, {format: 'json', ids: [media_resource.id], with: {parents: {pagination: {page: 2}}}}, valid_session(@user)
        json = JSON.parse(response.body)
        mr = json["media_resources"].first
        parents_pagination = mr["parents"]["pagination"] 
        expect(parents_pagination["page"]).to be== 2
        expect(
          parents_pagination["total"] - parents_pagination["per_page"]
        ).to be== mr["parents"]["media_resources"].size 
      end

      it "is forwarding only the explicit with for the parents to responding parents" do
        get :index, {format: 'json', ids: ids, with: {media_type: true, parents: true}}, valid_session(@user)
        json = JSON.parse(response.body)
        json["media_resources"].each do |mr|
          expect(mr.keys).to include("media_type")
          expect(mr.keys).to include("parents")
          mr["parents"]["media_resources"].each do |parent|
            expect(parent.keys).not_to include("media_type")
          end
        end
        get :index, {format: 'json', ids: ids, with: {media_type: true, parents: {with: {media_type: true}}}}, valid_session(@user)
        json = JSON.parse(response.body)
        json["media_resources"].each do |mr|
          mr["parents"]["media_resources"].each do |parent|
            expect(parent.keys).to include("media_type")
          end
        end
      end
    end

    describe "a response with children" do
      it "respond with a collection of resources and their children" do
        get :index, {format: 'json', ids: ids, with: {children: true}}, valid_session(@user)
        json = JSON.parse(response.body)
        json["media_resources"].each do |mr|
          expect(mr.keys).to include("children") if mr["type"] == "media_set"
        end 
      end

      it "respond with a collection of resources and their children with pagination" do
        get :index, {format: 'json', ids: ids, with: {children: true}}, valid_session(@user)
        expect(response).to be_success
        json = JSON.parse(response.body)
        json["media_resources"].each do |mr|
          if mr["type"] == "media_set"
            expect(mr.keys).to include("children")
            expect(mr["children"].keys).to include("pagination")
            expect(mr["children"]["pagination"]["total"]).to be== MediaResource.find(mr["id"]).child_media_resources.size            
          end
        end 
      end

      it "has paginatable childrens" do
        get :index, {format: 'json', with: {children: true}}, valid_session(@user)
        expect(response).to be_success
        json = JSON.parse(response.body)
        mr = json["media_resources"].detect {|mr| mr["type"] == "media_set" and mr["children"]["pagination"]["total"] > 0 }
        raise "no set with children found" if mr.blank?
        media_resource = MediaResource.find mr["id"]
        40.times {
          type = rand > 0.5 ? :media_entry : :media_set
          mr = FactoryGirl.create type, :user => @user
          media_resource.child_media_resources << mr
        }
        get :index, {format: 'json', ids: [media_resource.id], with: {children: true}}, valid_session(@user)
        expect(response).to be_success
        json = JSON.parse(response.body)
        mr = json["media_resources"].first
        children_pagination = mr["children"]["pagination"] 
        expect(mr["children"]["media_resources"].size).to be== children_pagination["per_page"]
        expect(children_pagination["total"]).to be >= 40
        expect(children_pagination["total_pages"]).to be > 1
        get :index, {format: 'json', ids: [media_resource.id], with: {children: {pagination: {page: 2}}}}, valid_session(@user)
        expect(response).to be_success
        json = JSON.parse(response.body)
        mr = json["media_resources"].first
        children_pagination = mr["children"]["pagination"] 
        expect(children_pagination["page"]).to be== 2
        expect(
          children_pagination["total"] - children_pagination["per_page"]
        ).to be== mr["children"]["media_resources"].size 
      end

      context "is forwarding only the explicit with for the children to responding children" do

        it "is not forwarding the root with" do
          get :index, {format: 'json', ids: ids, with: {media_type: true, children: true}}, valid_session(@user)
          json = JSON.parse(response.body)
          json["media_resources"].each do |mr|
            expect(mr.keys).to include("media_type")
            if mr["type"] == "media_set"
              expect(mr.keys).to include("children")
              mr["children"]["media_resources"].each do |child|
                expect(child.keys).not_to include("media_type")
              end
            end
          end
        end 

        it "is forwarding the media_type with" do
          get :index, {format: 'json', ids: ids, with: {media_type: true, children: {with: {media_type: true}}}}, valid_session(@user)
          json = JSON.parse(response.body)
          json["media_resources"].each do |mr|
            if mr["type"] == "media_set"
              mr["children"]["media_resources"].each do |child|
                expect(child.keys).to include("media_type")
              end
            end
          end
        end

        it "is forwarding the meta_data with" do
          get :index, {format: 'json', ids: ids, with: {children: {with: {meta_data: {context_ids: [@context.id]}}}}}, valid_session(@user)
          json = JSON.parse(response.body)
          json["media_resources"].each do |mr|
            if mr["type"] == "media_set"
              mr["children"]["media_resources"].each do |child|
                expect(child.keys).to include("meta_data")
              end
            end
          end
        end
      end
    end

    describe "a response with nested meta data" do

      describe "including the meta data type meta terms" do
        it "should respond with meta data meta terms" do
          mr = MediaResource.media_entries.first
          mk = FactoryGirl.create :meta_key, id: "Department", :meta_datum_object_type => "MetaDatumMetaTerms", :is_extensible_list => true
          mr.meta_data.create :meta_key => mk, :value => [Faker::Lorem.words(4).join(' '), Faker::Lorem.words(4).join(' ')]
          get :index, {format: 'json', ids: [mr.id], with: {meta_data: {meta_key_ids: [mk.label]}}}, valid_session(@user)
          expect(response).to be_success
          json = JSON.parse(response.body)
          json["media_resources"].each do |mr|
            mr["meta_data"].each do |md|
              expect(md["name"]).to be== "Department"
              expect(md["raw_value"].length).to be== 2
            end
          end
        end
      end

      describe "through meta contexts" do
        it "should respond with a collection of media resources with nested meta data for the core meta context" do
          get :index, {format: 'json', ids: ids, with: {meta_data: {context_ids: [@context.id]}}}, valid_session(@user)
          expect(response).to be_success
          json = JSON.parse(response.body)
          json["media_resources"].each do |mr|
            expect(mr["meta_data"].map{|x| x["name"]}.sort).to eq @context.meta_keys.pluck('meta_keys.id').sort
          end
        end        
      end

      describe "through meta contexts with a collection of provided ids" do
        it "should respond with the requested collection of media resources with nested meta data for the core meta context" do
          get :index, {format: 'json', ids: ids, with: {meta_data: {context_ids: [@context.id]}}}, valid_session(@user)
          expect(response).to be_success
          json = JSON.parse(response.body)
          json["media_resources"].each do |mr|
            expect(mr["meta_data"].map{|x| x["name"]}.sort).to be== @context.meta_keys.pluck('meta_keys.id').sort
          end
        end        
      end

      describe "through meta key names" do
        it "should respond with the requested collection of media resources with nested meta data for the given meta key names of a context beside core" do
          # a second meta context with keys (beside core)
          @another_context = FactoryGirl.create(:context)
          meta_key_definition = FactoryGirl.create(:meta_key_definition, :meta_key => FactoryGirl.create(:meta_key), :context => @another_context)
          meta_key_id = @another_context.meta_keys.first.to_s
          get :index, {format: 'json', ids: ids, with: {meta_data: {meta_key_ids: ["#{meta_key_id}"]}}}, valid_session(@user)
          expect(response).to be_success
          json = JSON.parse(response.body)
          json["media_resources"].each do |mr|
            expect(mr["meta_data"].first["name"]).to be== meta_key_id
          end
        end        
      end

      describe "through meta contexts with a single id provided" do
        it "should respond with the requested collection of media resources with nested meta data for the core meta context" do
          get :index, {format: 'json', ids: ids[0,1], with: {meta_data: {context_ids: [@context.id]}}}, valid_session(@user)
          expect(response).to be_success
          json = JSON.parse(response.body)
          json["media_resources"].each do |mr|
            expect(mr["meta_data"].map{|x| x["name"]}.sort).to eq @context.meta_keys.pluck('meta_keys.id').sort
          end
        end        
      end

      describe "a response filtered by media resource type" do
        it "should respond only with media entries when requested" do
          get :index, {format: 'json', type: "media_entries"}, valid_session(@user)
          expect(response).to be_success
          json = JSON.parse(response.body)
          json["media_resources"].each do |mr|
            expect(mr["type"]).to be== "media_entry"
          end
        end        
        it "should respond only with media sets when requested" do
          get :index, {format: 'json', type: "media_sets"}, valid_session(@user)
          expect(response).to be_success
          json = JSON.parse(response.body)
          json["media_resources"].each do |mr|
            expect(mr["type"]).to be== "media_set"
          end
        end        
      end
    end

    # TODO after TD, merge :filter to :index
    describe "filtering search result" do
      let :media_resource_ids do
        MediaResource.pluck(:id)
      end

      it "should respond with success" do
        get :index, {format: 'json'}, valid_session(@user)
        expect(response).to be_success
      end
      it "should filter only type MediaEntry" do
        get :index, {format: 'json', type: "media_entries"}, valid_session(@user)
        json = JSON.parse(response.body)
        expect(json["pagination"]["total"]).to be== MediaEntry.count
        expect(json["media_resources"].collect {|x| x["type"]}.uniq).to be== ["media_entry"]
      end
      it "should filter only type MediaSet" do
        get :index, {format: 'json', type: "media_sets"}, valid_session(@user)
        json = JSON.parse(response.body)
        expect(json["pagination"]["total"]).to be== MediaSet.count
        expect(json["media_resources"].collect {|x| x["type"]}.uniq).to be== ["media_set"]
      end
      it "should filter exactly the specific MediaResources" do
        mr_ids = media_resource_ids.shuffle[0, 5]
        get :index, {format: 'json', ids: mr_ids }, valid_session(@user)
        json = JSON.parse(response.body)
        expect(json["pagination"]["total"]).to be== 5
        expect(json["media_resources"].map{|x| x["id"]}.sort).to be== mr_ids.sort
      end
      it "should filter only MediaResources with image as MediaFile" do
        get :index, {format: 'json', media_file: {content_type: ["Image"]} }, valid_session(@user)
        json = JSON.parse(response.body)
        expect(json["pagination"]["total"]).to be==
          MediaEntry.joins(:media_file).where("media_files.content_type LIKE '%image%'").count
        expect(json["media_resources"].collect {|x| x["type"]}.uniq).to be== ["media_entry"]
      end
      it "should filter on orientation" do
        landscape, vertical, square = ["<", ">", "="].map do |operator|
          MediaEntry.joins(:media_file).where("media_files.height #{operator} media_files.width").count
        end
        get :index, {format: 'json', ids: media_resource_ids, media_file: {content_type: ["Image"], orientation: 0} }, valid_session(@user)
        json = JSON.parse(response.body)
        expect(json["pagination"]["total"]).to be== landscape
        get :index, {format: 'json', ids: media_resource_ids, media_file: {content_type: ["Image"], orientation: 1} }, valid_session(@user)
        json = JSON.parse(response.body)
        expect(json["pagination"]["total"]).to be== vertical
        get :index, {format: 'json', ids: media_resource_ids, media_file: {content_type: ["Image"], orientation: [0, 1]} }, valid_session(@user)
        json = JSON.parse(response.body)
        expect(json["pagination"]["total"]).to be== square
      end
    end

  end
end
