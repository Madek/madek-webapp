require 'spec_helper'

describe "Context" do |mc|

  it "should be producible by a factory" do
    expect(FactoryGirl.create :context).to_not be_nil
  end

  it "accepts empty meta context group foreign key" do
    expect{ FactoryGirl.create :context, context_group_id: "" }.to_not raise_error
  end

  context "when it is associated with a meta set" do
    it "should be deletable" do
      context = FactoryGirl.create :context
      context.media_sets << FactoryGirl.create(:media_set)
      
      expect(context.reload.media_sets.count).to be== 1
      expect{ context.destroy }.to_not raise_error
    end
  end
end
