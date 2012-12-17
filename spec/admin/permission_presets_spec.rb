require 'spec_helper'

describe Admin::PermissionPresetsController, :type => :controller do

  before :all do
    FactoryGirl.create :usage_term 
    FactoryGirl.create :meta_context_core
    PermissionPreset.destroy_all
    @adam = FactoryGirl.create :user, login: "adam"
    Group.find_or_create_by_name("Admin").users << @adam
  end

  def valid_attributes
    {name: "Nobody", view: false, download: false, edit: false, manage:false}
  end
  
  def valid_session
    {user_id: @adam.id}
  end

  describe "GET index" do
    it "assigns all permission_presets as @permission_presets" do
      permission_preset = PermissionPreset.create! valid_attributes
      get :index, {}, valid_session
      assigns(:permission_presets).should eq([permission_preset])
    end
  end

  describe "GET show" do
    it "assigns the requested permission_preset as @permission_preset" do
      permission_preset = PermissionPreset.create! valid_attributes
      get :show, {:id => permission_preset.to_param}, valid_session
      assigns(:permission_preset).should eq(permission_preset)
    end
  end

  describe "GET new" do
    it "assigns a new permission_preset as @permission_preset" do
      get :new, {}, valid_session
      assigns(:permission_preset).should be_a_new(PermissionPreset)
    end
  end

  describe "GET edit" do
    it "assigns the requested permission_preset as @permission_preset" do
      permission_preset = PermissionPreset.create! valid_attributes
      get :edit, {:id => permission_preset.to_param}, valid_session
      assigns(:permission_preset).should eq(permission_preset)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new PermissionPreset" do
        expect {
          post :create, {:permission_preset => valid_attributes}, valid_session
        }.to change(PermissionPreset, :count).by(1)
      end

      it "assigns a newly created permission_preset as @permission_preset" do
        post :create, {:permission_preset => valid_attributes}, valid_session
        assigns(:permission_preset).should be_a(PermissionPreset)
        assigns(:permission_preset).should be_persisted
      end

      it "redirects to the created permission_preset" do
        post :create, {:permission_preset => valid_attributes}, valid_session
        response.should redirect_to(admin_permission_preset_url PermissionPreset.last)
      end
    end

    describe "with invalid params" do

      it "assigns a newly created but unsaved permission_preset as @permission_preset" do
        post :create, {}, valid_session
        assigns(:permission_preset).should be_a_new(PermissionPreset)
      end

      it "re-renders the 'new' template" do
        post :create, {:permission_preset => {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested permission_preset" do
        permission_preset = PermissionPreset.create valid_attributes
        put :update, {:id => permission_preset.to_param, :permission_preset => permission_preset.attributes}, valid_session
      end

      it "assigns the requested permission_preset as @permission_preset" do
        permission_preset = PermissionPreset.create! valid_attributes
        put :update, {:id => permission_preset.to_param, :permission_preset => valid_attributes}, valid_session
        assigns(:permission_preset).should eq(permission_preset)
      end

      it "redirects to the permission_preset" do
        permission_preset = PermissionPreset.create! valid_attributes
        put :update, {:id => permission_preset.to_param, :permission_preset => valid_attributes}, valid_session
        response.should redirect_to(admin_permission_preset_url(permission_preset))
      end
    end

    describe "with invalid params" do
      it "assigns the permission_preset as @permission_preset" do
        permission_preset = PermissionPreset.create! valid_attributes
              put :update, {:id => permission_preset.to_param, :permission_preset => {}}, valid_session
        assigns(:permission_preset).should eq(permission_preset)
      end

    end
  end

  describe "DELETE destroy" do
    it "destroys the requested permission_preset" do
      permission_preset = PermissionPreset.create! valid_attributes
      expect {
        delete :destroy, {:id => permission_preset.to_param}, valid_session
      }.to change(PermissionPreset, :count).by(-1)
    end

    it "redirects to the permission_presets list" do
      permission_preset = PermissionPreset.create! valid_attributes
      delete :destroy, {:id => permission_preset.to_param}, valid_session
      response.should redirect_to(admin_permission_presets_url)
    end
  end

end
