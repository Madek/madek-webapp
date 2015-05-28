require 'spec_helper'

describe PermissionMaker do
  let(:media_set) { create(:media_set_with_children) }

  it 'raises error when initialized with no arguments' do
    expect { PermissionMaker.new }.to raise_error(ArgumentError)
  end

  context 'for Userpermission' do
    let(:user) { create(:user) }

    context 'when no children permissions are given' do
      let(:permission_params) do
        {
          userpermission: {
            view: '1',
            edit: '0',
            download: '0'
          }
        }
      end
      subject { PermissionMaker.new(media_set, user, permission_params) }

      it 'creates Userpermission only for the media set' do
        expect(Userpermission).to receive(:find_or_initialize_by)
                                    .with(user_id: user.id, media_resource_id: media_set.id)
                                    .and_call_original

        subject.call

        expect(
          Userpermission.find_by(user_id: user.id,
                                 media_resource_id: media_set.id,
                                 view: true,
                                 edit: false,
                                 download: false)
        ).to be

        media_set.child_media_resources.find_each do |child_resource|
          expect_no_userpermission_for(child_resource, user)
        end
      end
    end

    context 'when permissions for children media sets are given' do
      let(:permission_params) do
        {
          children_media_sets: {
            view: '1',
            edit: '1',
            download: '1'
          }
        }
      end
      subject { PermissionMaker.new(media_set, user, permission_params) }

      it 'creates Userpermission only for children media sets' do
        subject.call

        expect_no_userpermission_for(media_set, user)

        media_set.child_media_resources.media_sets.find_each do |ms|
          expect(
            Userpermission.find_by(user_id: user.id,
                                   media_resource_id: ms.id,
                                   view: true,
                                   edit: true,
                                   download: true)
          ).to be
        end

        media_set.child_media_resources.media_entries.find_each do |media_entry|
          expect_no_userpermission_for(media_entry, user)
        end
      end
    end

    context 'when permissions for children media entries are given' do
      let(:permission_params) do
        {
          children_media_entries: {
            view: '1',
            edit: '1',
            download: '1'
          }
        }
      end
      subject { PermissionMaker.new(media_set, user, permission_params) }

      it 'creates Userpermission only for children media entries' do
        subject.call

        expect_no_userpermission_for(media_set, user)

        media_set.child_media_resources.media_entries.find_each do |me|
          expect(
            Userpermission.find_by(user_id: user.id,
                                   media_resource_id: me.id,
                                   view: true,
                                   edit: true,
                                   download: true)
          ).to be
        end

        media_set.child_media_resources.media_sets.find_each do |ms|
          expect_no_userpermission_for(ms, user)
        end
      end
    end
  end

  context 'for Grouppermission' do
    let(:group) { create(:group) }

    context 'when no children permissions are given' do
      let(:permission_params) do
        {
          grouppermission: {
            view: '1',
            edit: '0',
            download: '0'
          }
        }
      end
      subject { PermissionMaker.new(media_set, group, permission_params) }

      it 'creates Grouppermission only for media set' do
        expect(Grouppermission).to receive(:find_or_initialize_by)
                                     .with(group_id: group.id, media_resource_id: media_set.id)
                                     .and_call_original

        subject.call

        expect(
          Grouppermission.find_by(group_id: group.id,
                                  media_resource_id: media_set.id,
                                  view: true,
                                  edit: false,
                                  download: false)
        ).to be

        media_set.child_media_resources.find_each do |child_resource|
          expect_no_userpermission_for(child_resource, group)
        end
      end
    end

    context 'when permissions for children media sets are given' do
      let(:permission_params) do
        {
          children_media_sets: {
            view: '1',
            edit: '1',
            download: '1'
          }
        }
      end
      subject { PermissionMaker.new(media_set, group, permission_params) }

      it 'creates Grouppermission only for children media sets' do
        subject.call

        expect_no_grouppermission_for(media_set, group)

        media_set.child_media_resources.media_sets.find_each do |ms|
          expect(
            Grouppermission.find_by(group_id: group.id,
                                    media_resource_id: ms.id,
                                    view: true,
                                    edit: true,
                                    download: true)
          ).to be
        end

        media_set.child_media_resources.media_entries.find_each do |me|
          expect_no_grouppermission_for(me, group)
        end
      end
    end

    context 'when permissions for children media entries are given' do
      let(:permission_params) do
        {
          children_media_entries: {
            view: '1',
            edit: '1',
            download: '1'
          }
        }
      end
      subject { PermissionMaker.new(media_set, group, permission_params) }

      it 'creates Grouppermission only for children media entries' do
        subject.call

        expect_no_grouppermission_for(media_set, group)

        media_set.child_media_resources.media_entries.find_each do |me|
          expect(
            Grouppermission.find_by(group_id: group.id,
                                   media_resource_id: me.id,
                                   view: true,
                                   edit: true,
                                   download: true)
          ).to be
        end

        media_set.child_media_resources.media_sets.find_each do |ms|
          expect_no_grouppermission_for(ms, group)
        end
      end
    end
  end

  def expect_no_grouppermission_for(resource, group)
    expect(
      Grouppermission.find_by(media_resource_id: resource.id, group_id: group.id)
    ).not_to be
  end

  def expect_no_userpermission_for(resource, user)
    expect(
      Userpermission.find_by(media_resource_id: resource.id, user_id: user.id)
    ).not_to be
  end
end
