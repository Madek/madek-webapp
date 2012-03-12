require 'spec_helper'

describe MetaContextGroup do
  
  it "should be producible by a factory" do
    (FactoryGirl.create :meta_context_group).should_not == nil
  end

  it "should only alow unique names" do
    expect {MetaContextGroup.create name: "TheName"}.not_to raise_error 
    expect {MetaContextGroup.create name: "TheName"}.to raise_error 
  end

  context "existing context_group and context" do

    before :all do
      @context_group = (FactoryGirl.create :meta_context_group)
      @context = (FactoryGirl.create :meta_context)
    end

    it "should be possible to append an context" do
      expect { @context_group.meta_contexts << @context }.not_to raise_error
      @context.meta_context_group.should == @context_group
    end

    it "should remove the group from the conext if the group is destroyed" do
      @context_group.meta_contexts << @context
      @context_group.destroy
      @context.reload().meta_context_group.should == nil
    end

  end

end
