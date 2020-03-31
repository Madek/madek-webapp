require 'spec_helper'

describe Presenters::MediaEntries::BatchDiffQuery do
  describe '.diff' do
    let(:media_entry_1) { create(:media_entry_with_title, title: 'foobar') }
    let(:media_entry_2) { create(:media_entry_with_title, title: 'barfoo') }

    context 'MetaDatum::Text' do
      context 'when values are equal' do
        it 'counts correctly' do
          create :media_entry_with_title, title: 'foo'
          create :media_entry_with_title, title: 'foo'

          expect(result('madek_core:title')).to eq(
            'meta_key_id' => 'madek_core:title',
            'max' => 2,
            'count' => 2
          )
        end
      end

      context 'when values are different' do
        it 'counts correctly' do
          create :media_entry_with_title, title: 'foobar'
          create :media_entry_with_title, title: 'barfoo'

          described_class.diff(MediaEntry, media_entries)

          expect(result('madek_core:title')).to eq(
            'meta_key_id' => 'madek_core:title',
            'max' => 1,
            'count' => 2
          )
        end
      end
    end

    context 'MetaDatum::TextDate' do
      context 'when values are equal' do
        it 'counts correctly' do
          create(:meta_datum_text_date,
                 string: '03.2020',
                 media_entry: media_entry_1)
          create(:meta_datum_text_date,
                 string: '03.2020',
                 media_entry: media_entry_2)

          expect(result('test:datestring')).to eq(
            'meta_key_id' => 'test:datestring',
            'max' => 2,
            'count' => 2
          )
        end
      end

      context 'when values are different' do
        it 'counts correctly' do
          create(:meta_datum_text_date,
                 string: '10.04.1989',
                 media_entry: media_entry_1)
          create(:meta_datum_text_date,
                 string: '13.07.2019',
                 media_entry: media_entry_2)

          expect(result('test:datestring')).to eq(
            'meta_key_id' => 'test:datestring',
            'max' => 1,
            'count' => 2
          )
        end
      end
    end

    context 'MetaDatum::JSON' do
      context 'when values are equal' do
        it 'counts correctly' do
          create(:meta_datum_json,
                 json: '{ "foo": "bar" }',
                 media_entry: media_entry_1)
          create(:meta_datum_json,
                 json: '{ "foo": "bar" }',
                 media_entry: media_entry_2)

          expect(result('test:json')).to eq(
            'meta_key_id' => 'test:json',
            'max' => 2,
            'count' => 2
          )
        end
      end

      context 'when values are different' do
        it 'counts correctly' do
          create(:meta_datum_json, media_entry: media_entry_1)
          create(:meta_datum_json,
                 json: '{ "foo": "bar" }',
                 media_entry: media_entry_2)

          expect(result('test:json')).to eq(
            'meta_key_id' => 'test:json',
            'max' => 1,
            'count' => 2
          )
        end
      end
    end

    context 'MetaDatum::Roles' do
      context 'when values are equal' do
        it 'counts correctly' do
          role_1 = create(:role)
          create(:role)
          person_1 = create(:person)
          person_2 = create(:person)
          mdr_1 = create(:meta_datum_roles,
                         media_entry: media_entry_1,
                         create_sample_data: false)
          mdr_2 = create(:meta_datum_roles,
                         media_entry: media_entry_2,
                         create_sample_data: false)

          create(:meta_datum_role, meta_datum: mdr_1, role: role_1, person: person_1)
          create(:meta_datum_role, meta_datum: mdr_1, role: nil, person: person_2)
          create(:meta_datum_role, meta_datum: mdr_2, role: role_1, person: person_1)
          create(:meta_datum_role, meta_datum: mdr_2, role: nil, person: person_2)

          expect(result('test:roles')).to eq(
            'meta_key_id' => 'test:roles',
            'max' => 2,
            'count' => 2
          )
        end
      end

      context 'when values are different' do
        it 'counts correctly' do
          create(:meta_datum_roles, media_entry: media_entry_1)
          create(:meta_datum_roles, media_entry: media_entry_2)

          expect(result('test:roles')).to eq(
            'meta_key_id' => 'test:roles',
            'max' => 1,
            'count' => 2
          )
        end
      end
    end

    context 'MetaDatum::Keywords' do
      context 'when values are equal' do
        it 'counts correctly' do
          keywords = create_list(:keyword, 3)
          create(:meta_datum_keywords, media_entry: media_entry_1, keywords: keywords)
          create(:meta_datum_keywords, media_entry: media_entry_2, keywords: keywords)

          expect(result('test:keywords')).to eq(
            'meta_key_id' => 'test:keywords',
            'max' => 2,
            'count' => 2
          )
        end
      end

      context 'when values are different' do
        it 'counts correctly' do
          create(:meta_datum_keywords, media_entry: media_entry_1)
          create(:meta_datum_keywords, media_entry: media_entry_2)

          expect(result('test:keywords')).to eq(
            'meta_key_id' => 'test:keywords',
            'max' => 1,
            'count' => 2
          )
        end
      end
    end

    context 'MetaDatum::People' do
      context 'when values are equal' do
        it 'counts correctly' do
          people = create_list(:person, 3)
          create(:meta_datum_people, media_entry: media_entry_1, people: people)
          create(:meta_datum_people, media_entry: media_entry_2, people: people)

          expect(result('test:people')).to eq(
            'meta_key_id' => 'test:people',
            'max' => 2,
            'count' => 2
          )
        end
      end

      context 'when values are different' do
        it 'counts correctly' do
          create(:meta_datum_people, media_entry: media_entry_1)
          create(:meta_datum_people, media_entry: media_entry_2)

          expect(result('test:people')).to eq(
            'meta_key_id' => 'test:people',
            'max' => 1,
            'count' => 2
          )
        end
      end
    end

    describe 'handling query for missing meta data type' do
      it 'raises error with missing meta data type' do
        create :media_entry_with_title, title: 'foo'
        create :media_entry_with_title, title: 'foo'

        expect do
          described_class.diff(MediaEntry, media_entries, covered_types: [])
        end.to raise_error(RuntimeError, /<MetaDatum::Text>/)
      end
    end
  end

  def result(meta_key_id)
    described_class.diff(MediaEntry, media_entries).detect do |i|
      i['meta_key_id'] == meta_key_id
    end
  end
end

def media_entries
  MediaEntry.search_with('foo')
end
