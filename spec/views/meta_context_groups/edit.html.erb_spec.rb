require 'spec_helper'

describe "meta_context_groups/edit" do
  before(:each) do
    @meta_context_group = assign(:meta_context_group, stub_model(MetaContextGroup,
      :name => "MyString"
    ))
  end

  it "renders the edit meta_context_group form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => meta_context_groups_path(@meta_context_group), :method => "post" do
      assert_select "input#meta_context_group_name", :name => "meta_context_group[name]"
    end
  end
end
