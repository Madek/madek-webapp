require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'thumb_api'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::FilterSets::FilterSetThumb do
  it_can_be 'dumped' do
    filter_set = FactoryGirl.create(:filter_set)

    unless MetaKey.find_by_id('madek:core:title')
      with_disabled_triggers do
        # TODO: remove as soon as the madek:core meta data is part of the test db
        FactoryGirl.create :meta_key_core_title
      end
    end

    meta_key = MetaKey.find_by_id('madek:core:title')

    FactoryGirl.create :meta_datum_text,
                       meta_key: meta_key,
                       filter_set: filter_set

    let(:presenter) \
      { described_class.new(filter_set, filter_set.responsible_user) }
  end

  it_responds_to 'privacy_status' do
    let(:resource_type) { :filter_set }
  end
end
