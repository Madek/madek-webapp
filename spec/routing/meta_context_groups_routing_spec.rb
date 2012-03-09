require "spec_helper"

describe MetaContextGroupsController do
  describe "routing" do

    it "routes to #index" do
      get("/meta_context_groups").should route_to("meta_context_groups#index")
    end

    it "routes to #new" do
      get("/meta_context_groups/new").should route_to("meta_context_groups#new")
    end

    it "routes to #show" do
      get("/meta_context_groups/1").should route_to("meta_context_groups#show", :id => "1")
    end

    it "routes to #edit" do
      get("/meta_context_groups/1/edit").should route_to("meta_context_groups#edit", :id => "1")
    end

    it "routes to #create" do
      post("/meta_context_groups").should route_to("meta_context_groups#create")
    end

    it "routes to #update" do
      put("/meta_context_groups/1").should route_to("meta_context_groups#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/meta_context_groups/1").should route_to("meta_context_groups#destroy", :id => "1")
    end

  end
end
