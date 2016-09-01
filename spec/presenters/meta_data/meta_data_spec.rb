require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::MetaData::MetaDataShow do
  it_can_be 'dumped' do
    let(:presenter) do
      media_entry = create(:media_entry)
      described_class.new(media_entry,
                          media_entry.responsible_user)
    end
  end
end
