require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::MediaEntries::MediaEntryShow do
  # TODO: fix CI bug and finish the test (relations, media_file)
  # it_can_be 'dumped' do

  #   media_entry = FactoryBot.create(:media_entry_with_image_media_file)

  #   unless MetaKey.find_by_id('madek_core:title')
  #     with_disabled_triggers do
  #       # TODO: remove as soon as the madek_core meta data is part of the test db
  #       MetaKey.create id: 'madek_core:title',
  #                      meta_datum_object_type: 'MetaDatum::Text'
  #       MetaKey.create id: 'madek_core:copyright_notice',
  #                      meta_datum_object_type: 'MetaDatum::Text'
  #       MetaKey.create id: 'madek_core:portrayed_object_date',
  #                      meta_datum_object_type: 'MetaDatum::TextDate'
  #     end
  #   end

  #   #############################################
  #   # different meta data for meta_datum_text

  #   meta_keys = []
  #   meta_keys << MetaKey.find_by_id('madek_core:title')
  #   meta_keys << MetaKey.find_by_id('madek_core:copyright_notice')
  #   meta_keys << \
  #     (MetaKey.find_by_id('description') \
  #       || FactoryBot.create(:meta_key_text, id: 'description'))

  #   meta_keys.each do |meta_key|
  #     FactoryBot.create :meta_datum_text,
  #                        meta_key: meta_key,
  #                        media_entry: media_entry
  #   end

  #   #############################################

  #   meta_key = MetaKey.find_by_id('madek_core:portrayed_object_date')
  #   FactoryBot.create :meta_datum_text_date,
  #                      meta_key: meta_key,
  #                      media_entry: media_entry

  #   #############################################

  #   meta_key = MetaKey.find_by_id('madek_core:keywords')
  #   meta_datum = \
  #     FactoryBot.create :meta_datum_keywords,
  #                        meta_key: meta_key,
  #                        media_entry: media_entry
  #   FactoryBot.create(:keyword, meta_datum: meta_datum)

  #   #############################################

  #   3.times { FactoryBot.create(:edit_session, media_entry: media_entry) }

  #   #############################################

  #   let(:presenter) \
  #     { described_class.new(media_entry, media_entry.responsible_user) }
  # end
end
