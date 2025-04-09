require 'spec_helper'

describe MediaEntries::Duplicator do
  describe '#new' do
    let(:dummy_entry) { MediaEntry.new }
    let(:dummy_user) { User.new }

    it 'raises ArgumentError for missing arguments' do
      expect { described_class.new }.to raise_error(ArgumentError)
      expect { described_class.new(dummy_entry) }.to raise_error(ArgumentError)
    end

    it 'accepts only MediaEntry instance as a first argument' do
      expect { described_class.new(dummy_entry, dummy_user) }.not_to raise_error
      expect { described_class.new(MediaEntry, dummy_user) }.to raise_error(TypeError)
      expect { described_class.new('MediaEntry', dummy_user) }.to raise_error(TypeError)
    end

    it 'accepts only User instance as a second argument' do
      expect { described_class.new(dummy_entry, dummy_user) }.not_to raise_error
      expect { described_class.new(dummy_entry, User) }.to raise_error(TypeError)
      expect { described_class.new(dummy_entry, 'User') }.to raise_error(TypeError)
    end

    it 'instantiates Configuration with empty hash' do
      expect(MediaEntries::Duplicator::Configuration).to receive(:new).with({})

      described_class.new(dummy_entry, dummy_user)
    end

    it 'passes configuration hash to Configuration' do
      random_config = {
        copy_meta_data: [true, false].sample,
        copy_permissions: [true, false].sample,
        copy_relations: [true, false].sample,
        copy_timestamps: [true, false].sample,
        move_custom_urls: [true, false].sample,
        remove_permissions_from_originator: [true, false].sample,
        annotate_as_new_version_of: [true, false].sample
      }.freeze

      expect(MediaEntries::Duplicator::Configuration).to receive(:new).with(random_config)

      described_class.new(dummy_entry, dummy_user, random_config)
    end
  end

  describe '#call' do
    let(:originator) do 
      create(:media_entry_with_title, :fat, {get_metadata_and_previews: true, get_full_size: true})
    end
    let(:user) { create(:user) }
    let(:config) { {} }
    let(:new_media_entry) { described_class.new(originator, user, config).call }

    it 'returns a new MediaEntry' do
      expect(new_media_entry).to be_instance_of(MediaEntry)
      expect(new_media_entry).to be_persisted
      expect(new_media_entry).not_to eq(originator)
    end

    it 'sets responsible user of the new entry to the user performing the operation' do
      expect(new_media_entry.responsible_user).to eq user
    end

    describe 'new MediaEntry' do
      describe 'copying timestamps' do
        context 'when copy_timestamps option is disabled' do
          it 'has different created_at timestamp than originator' do
            expect(new_media_entry.created_at).not_to eq(originator.created_at)
          end

          it 'has different updated_at timestamp than originator' do
            expect(new_media_entry.updated_at).not_to eq(originator.updated_at)
          end
        end

        context 'when copy_timestamps option is enabled' do
          let(:config) { { copy_timestamps: true } }

          it 'has the same created_at timestamp as originator' do
            expect(new_media_entry.created_at).to eq(originator.created_at)
          end

          it 'has the same updated_at timestamp as originator' do
            expect(new_media_entry.updated_at).to eq(originator.updated_at)
          end
        end
      end

      it 'has the title with suffix' do
        expect(new_media_entry.title).to eq(originator.title + ' (updated)')
      end

      describe 'copying meta data' do
        context 'MetaDatum::Text' do
          specify 'existence of meta data' do
            expect(meta_data_for(originator, 'MetaDatum::Text').size).to be_between(1, 3)
            expect(meta_data_for(originator, 'MetaDatum::Text').size)
              .to eq(meta_data_for(new_media_entry, 'MetaDatum::Text').size)
          end

          it 'copies meta data' do
            meta_data_for(originator, 'MetaDatum::Text') do |md|
              expect(find_new_md_for(new_media_entry, like: md)).to be
            end
          end
        end

        context 'MetaDatum::TextDate' do
          specify 'existence of meta data' do
            expect(meta_data_for(originator, 'MetaDatum::TextDate').size).to be_between(1, 3)
            expect(meta_data_for(originator, 'MetaDatum::TextDate').size)
              .to eq(meta_data_for(new_media_entry, 'MetaDatum::TextDate').size)
          end

          it 'copies meta data' do
            meta_data_for(originator, 'MetaDatum::TextDate') do |md|
              expect(find_new_md_for(new_media_entry, like: md)).to be
            end
          end
        end

        context 'MetaDatum::JSON' do
          specify 'existence of meta data' do
            expect(meta_data_for(originator, 'MetaDatum::JSON').size).to be_between(1, 3)
            expect(meta_data_for(originator, 'MetaDatum::JSON').size)
              .to eq(meta_data_for(new_media_entry, 'MetaDatum::JSON').size)
          end

          it 'copies meta data' do
            meta_data_for(originator, 'MetaDatum::JSON') do |md|
              expect(find_new_md_for(new_media_entry, like: md)).to be
            end
          end
        end

        context 'MetaDatum::Keywords' do
          specify 'existence of meta data' do
            expect(meta_data_for(originator, 'MetaDatum::Keywords').size).to be_between(1, 3)
            expect(meta_data_for(originator, 'MetaDatum::Keywords').size)
              .to eq(meta_data_for(new_media_entry, 'MetaDatum::Keywords').size)
          end

          it 'copies meta data' do
            meta_data_for(originator, 'MetaDatum::Keywords') do |md|
              new_md = find_new_md_for(new_media_entry, like: md)
              md.meta_data_keywords.each do |mdk|
                expect(
                  new_md
                    .meta_data_keywords
                    .find_by(keyword: mdk.keyword)
                ).to be
              end
            end
          end
        end

        context 'MetaDatum::People' do
          specify 'existence of meta data' do
            expect(meta_data_for(originator, 'MetaDatum::People').size).to be_between(1, 3)
            expect(meta_data_for(originator, 'MetaDatum::People').size)
              .to eq(meta_data_for(new_media_entry, 'MetaDatum::People').size)
          end

          it 'copies meta data' do
            meta_data_for(originator, 'MetaDatum::People') do |md|
              new_md = find_new_md_for(new_media_entry, like: md)
              md.meta_data_people.each do |mdp|
                expect(
                  new_md.meta_data_people.find_by(person: mdp.person, created_by: mdp.created_by)
                ).to be
              end
            end
          end
        end

        context 'MetaDatum::Roles' do
          specify 'existence of meta data' do
            expect(meta_data_for(originator, 'MetaDatum::Roles').size).to be_between(1, 3)
            expect(meta_data_for(originator, 'MetaDatum::Roles').size)
              .to eq(meta_data_for(new_media_entry, 'MetaDatum::Roles').size)
          end

          it 'copies meta data' do
            meta_data_for(originator, 'MetaDatum::Roles') do |md|
              new_md = find_new_md_for(new_media_entry, like: md)
              md.meta_data_roles.each do |mdr|
                expect(
                  new_md.meta_data_roles.find_by(
                    person: mdr.person,
                    role: mdr.role,
                    position: mdr.position
                  )
                ).to be
              end
            end
          end
        end
      end

      context 'when copy_permission config is set to false' do
        let(:config) { { copy_permissions: false } }

        it 'does not copy any permissions' do
          expect(originator.get_metadata_and_previews).to be true
          expect(originator.get_full_size).to be true
          expect(originator.user_permissions.size).to be_between(1, 3)
          expect(originator.group_permissions.size).to be_between(1, 3)
          expect(originator.api_client_permissions.size).to be_between(1, 3)

          expect(new_media_entry.get_metadata_and_previews).to be false
          expect(new_media_entry.get_full_size).to be false
          expect(new_media_entry.user_permissions.size).to be 0
          expect(new_media_entry.group_permissions.size).to be 0
          expect(new_media_entry.api_client_permissions.size).to be 0
        end
      end

      describe 'copying permissions' do
        it 'has the same view permission' do
          expect(new_media_entry.get_metadata_and_previews)
            .to eq(originator.get_metadata_and_previews)
        end

        it 'has the same get_full_size permission' do
          expect(new_media_entry.get_full_size)
            .to eq(originator.get_full_size)
        end

        context 'user permissions' do
          it 'has the same amount of user permissions' do
            expect(new_media_entry.user_permissions.size).to be_between(1, 3)
            expect(new_media_entry.user_permissions.size).to eq(originator.user_permissions.size)
          end

          it 'has the same user permissions' do
            originator.user_permissions.each do |up|
              expect(
                new_media_entry.user_permissions.find_by(
                  get_metadata_and_previews: up.get_metadata_and_previews,
                  get_full_size: up.get_full_size,
                  edit_metadata: up.edit_metadata,
                  edit_permissions: up.edit_permissions,
                  user: up.user,
                  updator: up.updator
                )
              ).to be
            end
          end
        end

        context 'group permissions' do
          it 'has the same amount of group permissions' do
            expect(new_media_entry.group_permissions.size).to be_between(1, 3)
            expect(new_media_entry.group_permissions.size).to eq(originator.group_permissions.size)
          end

          it 'has the same group permissions' do
            originator.group_permissions.each do |up|
              expect(
                new_media_entry.group_permissions.find_by(
                  get_metadata_and_previews: up.get_metadata_and_previews,
                  get_full_size: up.get_full_size,
                  edit_metadata: up.edit_metadata,
                  group: up.group,
                  updator: up.updator
                )
              ).to be
            end
          end
        end

        context 'api client permissions' do
          it 'has the same amount of api client permissions' do
            expect(new_media_entry.api_client_permissions.size).to be_between(1, 3)
            expect(new_media_entry.api_client_permissions.size)
              .to eq(originator.api_client_permissions.size)
          end

          it 'has the same api client permissions' do
            originator.api_client_permissions.each do |up|
              expect(
                new_media_entry.api_client_permissions.find_by(
                  get_metadata_and_previews: up.get_metadata_and_previews,
                  get_full_size: up.get_full_size,
                  api_client: up.api_client,
                  updator: up.updator
                )
              ).to be
            end
          end
        end
      end

      describe 'copying relations' do
        context 'parent collections' do
          let(:collection_1) { create(:collection, responsible_user: user) }
          let(:nested_collection_1) { create(:collection) }
          let(:nested_collection_2) { create(:collection) }
          let(:collection_2) { create(:collection, responsible_user: user) }
          let(:unaccessible_collection) { create(:collection) }

          before do
            collection_1.collections << nested_collection_1
            collection_1.media_entries << originator
            nested_collection_1.collections << nested_collection_2
            collection_2.media_entries << originator
            unaccessible_collection.media_entries << originator
          end

          it 'belongs to the same collections' do
            expect(new_media_entry.parent_collections.pluck(:id)).to eq(
              [
                collection_1.id,
                collection_2.id
              ]
            )
          end

          it 'does not belong to unaccessible collection' do
            expect(new_media_entry.parent_collections.pluck(:id))
              .not_to include(unaccessible_collection.id)
          end
        end

        context 'favorites' do
          let(:user_1) { create(:user) }
          let(:user_2) { create(:user) }

          before do
            originator.users_who_favored << [user_1, user_2]
          end

          it 'is favoritable for the same users' do
            expect(new_media_entry.users_who_favored.pluck(:id))
              .to contain_exactly(user_1.id, user_2.id)
          end
        end

        context 'custom URLs' do
          let!(:custom_url_1) { create(:custom_url, media_entry: originator) }
          let!(:custom_url_2) { create(:custom_url, media_entry: originator) }

          context 'when configuration option is set to true' do
            let(:config) { { move_custom_urls: true } }

            it 'moves custom URLs' do
              expect(new_media_entry.custom_urls).to match_array([custom_url_1, custom_url_2])
              expect(originator.custom_urls.reload).to be_empty
            end
          end

          context 'when configuration option is set to false (by default)' do
            it 'does not move custom URLs' do
              expect(new_media_entry.custom_urls).to be_empty
              expect(originator.custom_urls.reload).to match_array([custom_url_1, custom_url_2])
            end
          end
        end
      end

      describe 'annotating as previous version of other media entry' do
        context 'when configuration option is set to true' do
          let(:config) { { annotate_as_new_version_of: true } }

          it 'adds a proper meta data' do
            with_disabled_triggers do
              expect(
                new_media_entry.meta_data.find_by(
                  type: 'MetaDatum::MediaEntry',
                  meta_key_id: 'madek_core:is_new_version_of',
                  other_media_entry_id: originator.id,
                  string: 'Updated file',
                  created_by: new_media_entry.creator
                )
              ).to be
            end
          end
        end

        context 'when configuration option is set to false (by default)' do
          it 'does not add a meta data' do
            expect do
              new_media_entry.meta_data.find_by!(meta_key_id: 'madek_core:is_new_version_of')
            end.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end
end

def meta_data_for(resource, type, &block)
  meta_key_ids_exclusion = %w(madek_core:title madek_core:is_new_version_of)
  meta_data = resource
    .meta_data
    .where(type: type)
    .where.not(meta_key_id: meta_key_ids_exclusion)

  return meta_data.each(&block) if block_given?

  meta_data
end

def find_new_md_for(resource, like:)
  resource
    .meta_data
    .find_by!(
      type: like.type,
      meta_key: like.meta_key,
      string: like.string,
      json: like.json
    )
end
