require 'spec_helper'

describe WorkflowLocker::Service do
  let(:workflow) { create(:workflow) }
  let(:master_collection) { workflow.master_collection }
  let(:collection) { create(:collection) }
  let(:media_entry) { create(:media_entry_with_title) }
  let(:nested_media_entry) { create(:media_entry_with_title) }
  let(:meta_data) do
    {
      'Collection' => {
        master_collection.id => {
          'madek_core:title' => ['Master Collection']
        },
        collection.id => {
          'madek_core:title' => ['Some Collection']
        }
      },
      'MediaEntry' => {
        media_entry.id => {
          'madek_core:title' => ['Some Media Entry']
        },
        nested_media_entry.id => {
          'madek_core:title' => ['Nested Media Entry']
        }
      }
    }
  end
  let(:subject) { described_class.new(workflow, meta_data) }

  before do
    master_collection.collections << collection
    master_collection.media_entries << media_entry
    collection.media_entries << nested_media_entry
  end

  describe '#call' do
    context 'when workflow is active' do
      it 'performs without any error' do
        expect { subject.call }.not_to raise_error
      end
    end

    context 'when workflow is finished' do
      let(:workflow) { create(:finished_workflow) }

      it 'returns false' do
        expect(subject.call).to be false
      end
    end
  end

  describe '#save_only' do
    context 'when workflow is active' do
      it 'performs without any error' do
        expect { subject.save_only }.not_to raise_error
      end

      it 'updates titles for all resources' do
        subject.save_only

        expect(master_collection.title).to eq('Master Collection')
        expect(collection.title).to eq('Some Collection')
        expect(media_entry.title).to eq('Some Media Entry')
        expect(nested_media_entry.title).to eq('Nested Media Entry')
      end

      it 'returns true' do
        expect(subject.save_only).to be true
      end
    end

    context 'when workflow is finished' do
      let(:workflow) { create(:finished_workflow) }

      it 'returns false' do
        expect(subject.save_only).to be false
      end
    end
  end
end
