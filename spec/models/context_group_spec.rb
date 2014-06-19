require 'spec_helper'

describe ContextGroup do
  
  it "should be producible by a factory" do
    (FactoryGirl.create :context_group).should_not == nil
  end

  it "should only alow unique names" do
    expect {ContextGroup.create name: "TheName"}.not_to raise_error 
    expect {ContextGroup.create name: "TheName"}.to raise_error 
  end

  context "existing context_group and context" do

    before :each do
      @context_group = (FactoryGirl.create :context_group)
      @context = (FactoryGirl.create :context)
    end

    it "should be possible to append an context" do
      expect { @context_group.contexts << @context }.not_to raise_error
      @context.context_group.should == @context_group
    end

    it "should remove the group from the conext if the group is destroyed" do
      @context_group.contexts << @context
      @context_group.destroy
      @context.reload().context_group.should == nil
    end

  end

end
