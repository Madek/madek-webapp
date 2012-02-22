require 'spec_helper'

describe "permission_presets/new" do
  before(:each) do
    assign(:permission_preset, stub_model(PermissionPreset,
      :name => "MyString",
      :download => false,
      :view => false,
      :edit => false,
      :manage => false
    ).as_new_record)
  end

  it "renders new permission_preset form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => permission_presets_path, :method => "post" do
      assert_select "input#permission_preset_name", :name => "permission_preset[name]"
      assert_select "input#permission_preset_download", :name => "permission_preset[download]"
      assert_select "input#permission_preset_view", :name => "permission_preset[view]"
      assert_select "input#permission_preset_edit", :name => "permission_preset[edit]"
      assert_select "input#permission_preset_manage", :name => "permission_preset[manage]"
    end
  end
end
