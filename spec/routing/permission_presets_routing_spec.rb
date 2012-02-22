require "spec_helper"

describe Admin::PermissionPresetsController do
  describe "routing" do

    it "routes to #index" do
      get("/admin/permission_presets").should route_to("admin/permission_presets#index")
    end

    it "routes to #new" do
      get("/admin/permission_presets/new").should route_to("admin/permission_presets#new")
    end

    it "routes to #show" do
      get("/admin/permission_presets/1").should route_to("admin/permission_presets#show", :id => "1")
    end

    it "routes to #edit" do
      get("/admin/permission_presets/1/edit").should route_to("admin/permission_presets#edit", :id => "1")
    end

    it "routes to #create" do
      post("/admin/permission_presets").should route_to("admin/permission_presets#create")
    end

    it "routes to #update" do
      put("/admin/permission_presets/1").should route_to("admin/permission_presets#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/admin/permission_presets/1").should route_to("admin/permission_presets#destroy", :id => "1")
    end

  end
end
