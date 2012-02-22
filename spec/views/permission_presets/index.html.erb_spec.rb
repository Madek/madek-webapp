require 'spec_helper'

describe "permission_presets/index" do
  before(:each) do
    assign(:permission_presets, [
      stub_model(PermissionPreset,
        :name => "Name",
        :download => false,
        :view => false,
        :edit => false,
        :manage => false
      ),
      stub_model(PermissionPreset,
        :name => "Name",
        :download => false,
        :view => false,
        :edit => false,
        :manage => false
      )
    ])
  end

  it "renders a list of permission_presets" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => false.to_s, :count => 2
  end
end
