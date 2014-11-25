require 'spec_helper'

describe Permissions::MediaEntryApiClientPermission do

  it "is creatable via a factory" do
    expect{ FactoryGirl.create :media_entry_api_client_permission}.not_to raise_error
  end


  context "ApiClient and MediaEntry " do 

    before :each do 
      @api_client = FactoryGirl.create :api_client
      @creator = FactoryGirl.create :api_client
      @media_entry = FactoryGirl.create :media_entry
    end


    describe "destroy_ineffective" do

      context "for permission where all permission values are false and api_client is not the responsible_api_client" do
        before :each do 
          @permission= FactoryGirl.create(:media_entry_api_client_permission, 
                                          get_metadata_and_previews: false,
                                          get_full_size: false,
                                          api_client: (FactoryGirl.create :api_client),
                                          media_entry: @media_entry)
        end

        it "removes" do
          expect(Permissions::MediaEntryApiClientPermission.find_by id: @permission.id).to be
          Permissions::MediaEntryApiClientPermission.destroy_ineffective
          expect(Permissions::MediaEntryApiClientPermission.find_by id: @permission.id).not_to be
        end

      end

    end

  end

end
