require 'spec_helper'

describe "meta_context_groups/new" do
  before(:each) do
    assign(:meta_context_group, stub_model(MetaContextGroup,
      :name => "MyString"
    ).as_new_record)
  end

  it "renders new meta_context_group form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => meta_context_groups_path, :method => "post" do
      assert_select "input#meta_context_group_name", :name => "meta_context_group[name]"
    end
  end
end
