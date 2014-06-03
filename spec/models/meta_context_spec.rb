require 'spec_helper'

describe "MetaContext" do |mc|

  it "should be producible by a factory" do
    expect(FactoryGirl.create :meta_context).to_not be_nil
  end

  it "accepts empty meta context group foreign key" do
    expect{ FactoryGirl.create :meta_context, meta_context_group_id: "" }.to_not raise_error
  end

  context "when it is associated with a meta set" do
    it "should be deletable" do
      meta_context = FactoryGirl.create :meta_context
      meta_context.media_sets << FactoryGirl.create(:media_set)
      
      expect(meta_context.reload.media_sets.count).to be== 1
      expect{ meta_context.destroy }.to_not raise_error
    end
  end
end
