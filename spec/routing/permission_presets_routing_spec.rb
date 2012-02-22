require "spec_helper"

describe PermissionPresetsController do
  describe "routing" do

    it "routes to #index" do
      get("/permission_presets").should route_to("permission_presets#index")
    end

    it "routes to #new" do
      get("/permission_presets/new").should route_to("permission_presets#new")
    end

    it "routes to #show" do
      get("/permission_presets/1").should route_to("permission_presets#show", :id => "1")
    end

    it "routes to #edit" do
      get("/permission_presets/1/edit").should route_to("permission_presets#edit", :id => "1")
    end

    it "routes to #create" do
      post("/permission_presets").should route_to("permission_presets#create")
    end

    it "routes to #update" do
      put("/permission_presets/1").should route_to("permission_presets#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/permission_presets/1").should route_to("permission_presets#destroy", :id => "1")
    end

  end
end
