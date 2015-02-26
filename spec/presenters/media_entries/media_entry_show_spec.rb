require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::MediaEntries::MediaEntryShow do
  it 'dummy' do
    # for the rspec updator
  end

  # TODO: fix CI bug and finish the test (relations, media_file)
  # it_can_be 'dumped' do

  #   media_entry = FactoryGirl.create(:media_entry_with_image_media_file)

  #   unless MetaKey.find_by_id('madek:core:title')
  #     with_disabled_triggers do
  #       # TODO: remove as soon as the madek:core meta data is part of the test db
  #       MetaKey.create id: 'madek:core:title',
  #                      meta_datum_object_type: 'MetaDatum::Text'
  #       MetaKey.create id: 'madek:core:copyright_notice',
  #                      meta_datum_object_type: 'MetaDatum::Text'
  #       MetaKey.create id: 'madek:core:portrayed_object_date',
  #                      meta_datum_object_type: 'MetaDatum::TextDate'
  #     end
  #   end

  #   #############################################
  #   # different meta data for meta_datum_text

  #   meta_keys = []
  #   meta_keys << MetaKey.find_by_id('madek:core:title')
  #   meta_keys << MetaKey.find_by_id('madek:core:copyright_notice')
  #   meta_keys << \
  #     (MetaKey.find_by_id('description') \
  #       || FactoryGirl.create(:meta_key_text, id: 'description'))

  #   meta_keys.each do |meta_key|
  #     FactoryGirl.create :meta_datum_text,
  #                        meta_key: meta_key,
  #                        media_entry: media_entry
  #   end

  #   #############################################

  #   meta_key = MetaKey.find_by_id('madek:core:portrayed_object_date')
  #   FactoryGirl.create :meta_datum_text_date,
  #                      meta_key: meta_key,
  #                      media_entry: media_entry

  #   #############################################

  #   meta_key = MetaKey.find_by_id('madek:core:keywords')
  #   meta_datum = \
  #     FactoryGirl.create :meta_datum_keywords,
  #                        meta_key: meta_key,
  #                        media_entry: media_entry
  #   FactoryGirl.create(:keyword, meta_datum: meta_datum)

  #   #############################################

  #   3.times { FactoryGirl.create(:edit_session, media_entry: media_entry) }

  #   #############################################

  #   let(:presenter) \
  #     { described_class.new(media_entry, media_entry.responsible_user) }
  # end
end
