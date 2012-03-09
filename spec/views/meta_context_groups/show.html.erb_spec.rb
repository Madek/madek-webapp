require 'spec_helper'

describe "meta_context_groups/show" do
  before(:each) do
    @meta_context_group = assign(:meta_context_group, stub_model(MetaContextGroup,
      :name => "Name"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
  end
end
