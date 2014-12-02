require 'spec_helper'
require Rails.root.join "spec", "models", "shared", "destroy_ineffective_permissions_spec.rb"

describe Permissions::FilterSetGroupPermission do

  it "is creatable via a factory" do
    expect{ FactoryGirl.create :filter_set_group_permission}.not_to raise_error
  end


  context "Group and FilterSet " do

    before :each do
      @group = FactoryGirl.create :group
      @creator = FactoryGirl.create :group
      @filter_set = FactoryGirl.create :filter_set
    end


    describe "destroy_ineffective" do

      context "for permission where all permission values are false and group is not the responsible_group" do
        before :each do
          @permission= FactoryGirl.create(:filter_set_group_permission,
                                          get_metadata_and_previews: false,
                                          edit_metadata_and_filter: false,
                                          group: (FactoryGirl.create :group),
                                          filter_set: @filter_set)
        end

        it_destroys "ineffective permissions" do
          let(:permission) { @permission }
        end

      end

    end

  end

end
