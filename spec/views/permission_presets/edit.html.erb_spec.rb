require 'spec_helper'

describe "permission_presets/edit" do
  before(:each) do
    @permission_preset = assign(:permission_preset, stub_model(PermissionPreset,
      :name => "MyString",
      :download => false,
      :view => false,
      :edit => false,
      :manage => false
    ))
  end

  it "renders the edit permission_preset form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => permission_presets_path(@permission_preset), :method => "post" do
      assert_select "input#permission_preset_name", :name => "permission_preset[name]"
      assert_select "input#permission_preset_download", :name => "permission_preset[download]"
      assert_select "input#permission_preset_view", :name => "permission_preset[view]"
      assert_select "input#permission_preset_edit", :name => "permission_preset[edit]"
      assert_select "input#permission_preset_manage", :name => "permission_preset[manage]"
    end
  end
end
