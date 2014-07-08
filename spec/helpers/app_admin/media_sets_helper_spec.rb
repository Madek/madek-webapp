require 'spec_helper'

describe AppAdmin::MediaSetsHelper do
  describe "#active_context_for_media_set?" do
    before :each do
      @user = FactoryGirl.create :user
      @media_set = FactoryGirl.create :media_set, :user => @user
      @context = FactoryGirl.create :context
    end

    context "the context is an individual context" do
      it "returns true" do
        @media_set.individual_contexts << @context

        expect(helper.active_context_for_media_set?(@media_set, @context)).to be_true
      end
    end

    context "the context is not an individual context" do
      it "returns false" do
        expect(helper.active_context_for_media_set?(@media_set, @context)).to be_false
      end
    end
  end
end
