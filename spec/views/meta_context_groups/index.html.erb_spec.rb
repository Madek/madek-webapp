require 'spec_helper'

describe "meta_context_groups/index" do
  before(:each) do
    assign(:meta_context_groups, [
      stub_model(MetaContextGroup,
        :name => "Name"
      ),
      stub_model(MetaContextGroup,
        :name => "Name"
      )
    ])
  end

  it "renders a list of meta_context_groups" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
  end
end
