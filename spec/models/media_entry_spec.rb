require 'spec_helper'
require Rails.root.join "spec", "models", "shared", "favoritable_spec.rb"
require Rails.root.join "spec", "models", "shared", "edit_sessions_spec.rb"

describe MediaEntry do

  describe "Creation" do

    it "should be producible by a factory" do
      expect{ FactoryGirl.create :media_entry}.not_to raise_error
    end

  end

  context "an existing MediaEntry" do

    it_behaves_like "a favoritable" do

      let(:resource) { FactoryGirl.create :media_entry }

    end

    it_has "edit sessions" do

      let(:resource_type) { :media_entry }

    end

  end
end
