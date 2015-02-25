require 'spec_helper'
require Rails.root.join 'spec',
                        'models',
                        'shared',
                        'destroy_ineffective_permissions.rb'

describe Permissions::MediaEntryApiClientPermission do

  it 'is creatable via a factory' do
    expect { FactoryGirl.create :media_entry_api_client_permission }
      .not_to raise_error
  end

  context 'ApiClient and MediaEntry ' do

    before :each do
      @api_client = FactoryGirl.create :api_client
      @creator = FactoryGirl.create :api_client
      @media_entry = FactoryGirl.create :media_entry
    end

    describe 'destroy_ineffective' do

      context %(for permission where all permission values are false \
                and api_client is not the responsible_api_client) do
        before :each do
          @permission = \
            FactoryGirl.create(:media_entry_api_client_permission,
                               get_metadata_and_previews: false,
                               get_full_size: false,
                               api_client: (FactoryGirl.create :api_client),
                               media_entry: @media_entry)
        end

        it_destroys 'ineffective permissions' do
          let(:permission) { @permission }
        end

      end

    end

  end

end
