RSpec.shared_context 'select media resources' do
  def select_media_entries(arr)
    arr.select { |el| el.is_a? Presenters::MediaEntries::MediaEntryIndex }
  end

  def select_collections(arr)
    arr.select { |el| el.is_a? Presenters::Collections::CollectionIndex }
  end
end
