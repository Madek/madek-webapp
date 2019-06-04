require 'spec_helper'
require 'spec_helper_feature'
require 'spec_helper_feature_shared'

require_relative '../shared/meta_data_helper_spec'
include MetaDataHelper

require_relative '../shared/basic_data_helper_spec'
include BasicDataHelper

require_relative '../shared/context_meta_data_helper_spec'
include ContextMetaDataHelper

doc = <<-DOC
Action: Updating

"Create", "Add Value", "Modify Value" and "Delete" Metadata

Tested variations :
1. a. MD::Text exists, value is present: update MD
1. b. MD::People exists, value is present: update MD
1. c. MD::Roles exists, value is present: update MD
2. MD exists, value is empty: delete MD
3. MD does not exist, value is present: create MD
4. MD does not exist, value is empty: ignore/skip

(MD="A MetaDatum for this MetaKey on this Resource")
DOC

feature 'Resource: MediaEntry' do
  describe 'Concern: MetaData' do

    describe doc do

      scenario 'update via Javascript Models (unit test)' do

        prepare_data
        login

        config = {
          entry: media_entry_path(@resource),
          meta_key_id: 'madek_core:title',
          values: ['New Title']
        }

        # changes the configured key to value and saves to server:
        # response is a forward url or errors
        response = js_integration_test 'MediaEntryMetaData', config
        expect(response['body']['forward_url'])
          .to eq media_entry_path(@resource)

        # expect the change to reflected in db
        expect(find_datum(@resource, config[:meta_key_id]).string)
          .to eq 'New Title'
      end

      it 'edit full form', browser: :firefox do

        prepare_manipulate_and_check(
          {
            full: true,
            context: nil,
            async: true
          },
          lambda do
            prepare_data
          end,
          lambda do
            update_text_field('madek_core:title', 'New Title')
            update_bubble('madek_core:authors', person_name(@co_author))
            update_text_field('madek_core:description', '')
            update_bubble('media_object:creator', person_name(@creator))
            clean_context_roles_field(
              'media_object',
              'media_object:roles_movie',
              full: true)

            # FIXME: correct person is selected in UI but wrong person is saved!!!
            binding.pry

            update_context_roles_field(
              'media_object',
              'media_object:roles_music',
              @person_with_role,
              full: true)

          end,
          lambda do
            expect(find_datum(@resource, 'madek_core:title').string)
              .to eq 'New Title'
            expect(find_datum(@resource, 'madek_core:authors').try(:people))
              .to include(@author)
            expect(find_datum(@resource, 'madek_core:authors').try(:people))
              .to include(@co_author)
            expect(find_datum(@resource, 'madek_core:authors')
              .try(:people).length).to eq(2)
            expect(find_datum(@resource, 'madek_core:description')).to eq nil
            expect(find_datum(@resource, 'media_object:creator').try(:people))
              .to eq([@creator])
            expect(find_datum(@resource, 'madek_core:portrayed_object_date'))
              .to eq nil
            expect(find_datum(@resource, 'media_object:roles_movie')).to be_nil
            expect(find_datum(@resource, 'media_object:roles_music').value.size)
              .to eq 1
            expect(
              find_datum(@resource, 'media_object:roles_music').value.first.person)
                .to eq @person_with_role
            expect(
              find_datum(@resource, 'media_object:roles_music').value.first.role)
                .to be
            expect(find_datum(@resource, 'media_object:theater')).to be_nil
          end
        )
      end

      it 'edit context form', browser: :firefox do

        prepare_manipulate_and_check(
          {
            full: false,
            context: 'media_content',
            async: true
          },
          lambda do
            prepare_data
          end,
          lambda do
            update_context_text_field(
              'media_content',
              'madek_core:title',
              'New Title')
            update_context_bubble(
              'media_content',
              'madek_core:authors',
              person_name(@co_author))
            update_context_text_field(
              'media_content',
              'madek_core:description',
              '')
            clean_context_roles_field(
              'media_object',
              'media_object:roles_movie')
            update_context_roles_field(
              'media_object',
              'media_object:roles_music',
              @person_with_role)
          end,
          lambda do
            expect(find_datum(@resource, 'madek_core:title').string)
              .to eq 'New Title'
            expect(find_datum(@resource, 'madek_core:authors').try(:people))
              .to include(@author)
            expect(find_datum(@resource, 'madek_core:authors').try(:people))
              .to include(@co_author)
            expect(find_datum(@resource, 'madek_core:authors')
              .try(:people).length).to eq(2)
            expect(find_datum(@resource, 'madek_core:description')).to be_nil
            expect(find_datum(@resource, 'madek_core:portrayed_object_date'))
              .to be_nil
            expect(find_datum(@resource, 'media_object:roles_movie')).to be_nil
            expect(find_datum(@resource, 'media_object:roles_music').value.size)
              .to eq 1
            expect(
              find_datum(@resource, 'media_object:roles_music').value.first.person)
                .to eq @person_with_role
            expect(
              find_datum(@resource, 'media_object:roles_music').value.first.role)
                .to be
            expect(find_datum(@resource, 'media_object:theater')).to be_nil
          end
        )
      end
    end
  end
end

def person_name(person)
  person.first_name + ' ' + person.last_name
end

def prepare_data
  prepare_user
  @resource = create_media_entry('Test Media Entry')
  @author = create_or_find_person('Author')
  @co_author = create_or_find_person('Co-Author')
  @creator = create_or_find_person('Creator')
  prepare_roles

  add_authors_datum(@resource, [@author])
  expect(find_datum(@resource, 'madek_core:authors').people.length).to eq 1

  add_creators_datum(@resource, [])

  @resource.reload
end

def prepare_roles
  mk_roles_movie = create(
    :meta_key_roles,
    labels: { de: 'Rollen (Film)' },
    id: 'media_object:roles_movie')
  mk_roles_music = create(
    :meta_key_roles,
    labels: { de: 'Rollen (Musik)' },
    id: 'media_object:roles_music')
  mk_roles_theater = create(
    :meta_key_roles,
    labels: { de: 'Rollen (Theater)' },
    id: 'media_object:roles_theater')

  create_roles_for(mk_roles_movie, mk_roles_music, mk_roles_theater)
  create_context_key_for(mk_roles_movie, mk_roles_music, mk_roles_theater)

  add_roles_datum(@resource, mk_roles_movie.id)

  md = find_datum(@resource, 'media_object:roles_movie')
  expect(md.meta_data_roles.where(role_id: nil).size).to eq 1
  expect(md.meta_data_roles.where.not(role_id: nil).size).to eq 3

  @person_with_role = create_or_find_person 'Ruby master'
end

def create_roles_for(*meta_keys)
  meta_keys.each do |meta_key|
    3.times { create :role, meta_key: meta_key }
  end
end

def create_context_key_for(*meta_keys)
  context = Context.find('media_object')
  meta_keys.each do |meta_key|
    create(
      :context_key,
      labels: { de: nil },
      meta_key: meta_key,
      context: context)
  end
end
