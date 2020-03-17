require 'spec_helper'
require Rails.root.join 'spec', 'presenters', 'shared', 'dump'

describe Presenters::People::PersonShow do
  before :example do
    @user = FactoryGirl.create(:user)
    @person = FactoryGirl.create(
      :person,
      user: @user,
      first_name: 'Albert',
      last_name: 'Einstein',
      pseudonym: nil,
      external_uris: [
        # AuthorityControl links
        'https://viaf.org/viaf/75121530',
        'https://id.loc.gov/authorities/names/n79022889',
        'https://d-nb.info/gnd/118529579',
        # normal links
        'https://www.nobelprize.org/prizes/physics/1921/einstein/',
        # bare link
        'example.com',
        # invalid link (should not be in DB< but make sure it does not crash)
        'NOT_EVEN_A_LINK_BUT_DOES_NOT_CRASH'
      ])
  end

  it_can_be 'dumped' do
    let(:presenter) do
      described_class.new(@person, @user, nil, {})
    end
  end

  it 'has correct data' do
    entry = FactoryGirl.create(
      :media_entry_with_title, get_metadata_and_previews: true)
    FactoryGirl.create(
      :meta_datum_people, media_entry: entry, people: [@person])

    presenter = described_class.new(@person, @user, nil, {})
    dump = presenter.dump

    related_resources = dump[:resources][:resources]
    expect(related_resources.length).to be 1
    expect(related_resources[0][:uuid]).to eq entry.id

    expect(
      dump.except(:created_at, :updated_at, :resources, :_presenter)
    ).to eq(
      type: 'Person',
      name: 'Albert Einstein',
      to_s: 'Albert Einstein',
      label: 'Albert Einstein',
      description: nil,
      first_name: 'Albert',
      last_name: 'Einstein',
      url: "/people/#{@person.id}",
      uuid: @person.id,
      external_uris: [
        'https://viaf.org/viaf/75121530',
        'https://id.loc.gov/authorities/names/n79022889',
        'https://d-nb.info/gnd/118529579',
        'https://www.nobelprize.org/prizes/physics/1921/einstein/',
        'example.com',
        'NOT_EVEN_A_LINK_BUT_DOES_NOT_CRASH'
      ],
      actions: {
        edit: {
          url: "/people/#{@person.id}/edit"
        }
      }
    )
  end

end
