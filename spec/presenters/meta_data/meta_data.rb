require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::MetaData::MetaDataPresenter do
  it_can_be 'dumped' do
    media_entry = MediaEntry.first
    let(:presenter) do
      described_class.new(media_entry,
                          media_entry.responsible_user)
    end
  end
end
