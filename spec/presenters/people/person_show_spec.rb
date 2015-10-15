require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::People::PersonShow do
  it '#related_media_resources_via_meta_data' do

    # - create User with Person
    # - one entry uses the Person in MetaDatum
    # - another entry uses the User in MetaDatum
    # - then both should be "related via meta data"

    person = FactoryGirl.create(:person)
    user = FactoryGirl.create(:user, person: person)
    entry_via_person = FactoryGirl.create(:media_entry)

    [entry_via_person].each do |entry|
      FactoryGirl.create(:media_entry_user_permission,
                         user: user,
                         media_entry: entry,
                         get_metadata_and_previews: true)
    end

    FactoryGirl.create(:meta_datum_people,
                       media_entry: entry_via_person,
                       people: [person])

    get = described_class.new(person, user)

    expect(get.related_media_resources_via_meta_data.media_entries.resources
      .map(&:uuid))
      .to match_array [entry_via_person.id]

  end

  it_can_be 'dumped' do
    user = FactoryGirl.create(:user)
    let(:presenter) do
      described_class.new(user.person,
                          User.all.sample)
    end
  end
end
