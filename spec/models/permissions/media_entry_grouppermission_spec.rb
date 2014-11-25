require 'spec_helper'

describe Permissions::MediaEntryGrouppermission do

  it "is creatable via a factory" do
    expect{ FactoryGirl.create :media_entry_grouppermission}.not_to raise_error
  end


  context "Group and MediaEntry " do 

    before :each do 
      @group = FactoryGirl.create :group
      @creator = FactoryGirl.create :group
      @media_entry = FactoryGirl.create :media_entry
    end


    describe "destroy_ineffective" do

      context "for permission where all permission values are false and group is not the responsible_group" do
        before :each do 
          @permission= FactoryGirl.create(:media_entry_grouppermission, 
                                          get_metadata_and_previews: false,
                                          get_full_size: false,
                                          edit_metadata: false,
                                          group: (FactoryGirl.create :group),
                                          media_entry: @media_entry)
        end

        it "removes" do
          expect(Permissions::MediaEntryGrouppermission.find_by id: @permission.id).to be
          Permissions::MediaEntryGrouppermission.destroy_ineffective
          expect(Permissions::MediaEntryGrouppermission.find_by id: @permission.id).not_to be
        end

      end

    end

  end

end
