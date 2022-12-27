require 'spec_helper'

describe MediaEntriesController do
  describe '#rdf_export' do
    let(:user) { create(:user) }
    let(:media_entry) { create(:media_entry_with_title, responsible_user: user) }

    before do
      expect(Presenters::MediaEntries::MediaEntryRdfExport)
        .to receive(:new)
        .with(media_entry, user)
        .and_call_original
    end

    context 'rdf format' do
      before do
        expect_any_instance_of(Presenters::MediaEntries::MediaEntryRdfExport)
          .to receive(:rdf_xml).and_return(double)
      end

      context 'when plain text was requested' do
        it 'responds correctly' do
          get(
            :rdf_export,
            params: { id: media_entry, format: 'rdf', txt: 1 },
            session: { user_id: user.id }
          )

          expect(response.content_type).to eq('text/plain; charset=utf-8')
        end
      end

      context 'when an attachment was requested' do
        it 'responds correctly with attachment' do
          get(
            :rdf_export,
            params: { id: media_entry, format: 'rdf' },
            session: { user_id: user.id }
          )

          expect(response.content_type).to start_with('application/rdf+xml')
          expect(response.headers['Content-Disposition'])
            .to eq("attachment; filename=#{media_entry.id}.rdf")
        end
      end
    end

    context 'turtle format' do
      before do
        expect_any_instance_of(Presenters::MediaEntries::MediaEntryRdfExport)
          .to receive(:rdf_turtle)
      end

      context 'when plain text was requested' do
        it 'responds correctly' do
          get(
            :rdf_export,
            params: { id: media_entry, format: 'ttl', txt: 1 },
            session: { user_id: user.id }
          )

          expect(response.content_type).to eq('text/plain; charset=utf-8')
        end
      end

      context 'when an attachment was requested' do
        it 'responds correctly with attachment' do
          get(
            :rdf_export,
            params: { id: media_entry, format: 'ttl' },
            session: { user_id: user.id }
          )

          expect(response.content_type).to start_with('text/turtle')
          expect(response.headers['Content-Disposition'])
            .to eq("attachment; filename=#{media_entry.id}.ttl")
        end
      end
    end

    context 'JSON-LD format' do
      before do
        expect_any_instance_of(Presenters::MediaEntries::MediaEntryRdfExport)
          .to receive(:json_ld)
      end

      context 'when plain text was requested' do
        it 'responds correctly' do
          get(
            :rdf_export,
            params: { id: media_entry, format: 'json', txt: 1 },
            session: { user_id: user.id }
          )

          expect(response.content_type).to eq('text/plain; charset=utf-8')
        end
      end

      context 'when an attachment was requested' do
        it 'responds correctly with attachment' do
          get(
            :rdf_export,
            params: { id: media_entry, format: 'json' },
            session: { user_id: user.id }
          )

          expect(response.content_type).to start_with('application/json; charset=utf-8')
          expect(response.headers['Content-Disposition'])
            .to eq("attachment; filename=#{media_entry.id}.ld.json")
        end
      end
    end
  end
end
