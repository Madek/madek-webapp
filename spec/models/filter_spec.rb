require 'spec_helper'
require Rails.root.join "spec", "models", "shared", "edit_sessions_spec.rb"

describe Collection do

  describe "Creation" do

    it "should be producible by a factory" do
      expect{ FactoryGirl.create :filter_set}.not_to raise_error
    end

  end

  context "an existing Collection" do


    it_has "edit sessions" do

      let(:resource_type) { :media_entry }

    end

  end
end
