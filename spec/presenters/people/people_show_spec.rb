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
        'https://viaf.org/viaf/75121530',
        'https://id.loc.gov/authorities/names/n79022889',
        'https://d-nb.info/gnd/118529579'
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
        {
          uri: 'https://viaf.org/viaf/75121530',
          is_web: true,
          authority_control: {
            kind: :VIAF,
            label: '75121530',
            provider: {
              name: 'Virtual International Authority File',
              label: 'VIAF',
              url: 'https://viaf.org'
            }
          }
        },
        {
          uri: 'https://id.loc.gov/authorities/names/n79022889',
          is_web: true,
          authority_control: {
            kind: :LCCN,
            label: 'n79022889',
            provider: {
              name: 'Library of Congress Control Number',
              label: 'LCCN',
              url: 'https://lccn.loc.gov/lccnperm-faq.html'
            }
          }
        },
        {
          uri: 'https://d-nb.info/gnd/118529579',
          is_web: true,
          authority_control: {
            kind: :GND,
            label: '118529579',
            provider: {
              name: 'Gemeinsame Normdatei',
              label: 'GND',
              url: 'https://www.dnb.de/DE/Standardisierung/GND/gnd_node.html'
            }
          }
        }
      ]
    )
  end

end
