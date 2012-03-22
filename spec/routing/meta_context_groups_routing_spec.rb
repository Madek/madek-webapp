require "spec_helper"

describe Admin::MetaContextGroupsController do
  describe "routing" do

    it "routes to #index" do
      get("/admin/meta_context_groups").should route_to("admin/meta_context_groups#index")
    end

    it "routes to #new" do
      get("/admin/meta_context_groups/new").should route_to("admin/meta_context_groups#new")
    end

    it "routes to #show" do
      get("/admin/meta_context_groups/1").should route_to("admin/meta_context_groups#show", :id => "1")
    end

    it "routes to #edit" do
      get("/admin/meta_context_groups/1/edit").should route_to("admin/meta_context_groups#edit", :id => "1")
    end

    it "routes to #create" do
      post("/admin/meta_context_groups").should route_to("admin/meta_context_groups#create")
    end

    it "routes to #update" do
      put("/admin/meta_context_groups/1").should route_to("admin/meta_context_groups#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/admin/meta_context_groups/1").should route_to("admin/meta_context_groups#destroy", :id => "1")
    end

  end
end
