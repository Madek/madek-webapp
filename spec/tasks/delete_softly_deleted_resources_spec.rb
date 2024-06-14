require 'spec_helper'

describe 'delete soft deleted resources tasks' do
  before(:each) do
    Rails.application.load_tasks
    create(:app_setting, site_titles: { en: "Madek", de: "Medienarchiv" })
  end

  before(:each) do
    @media_entry_1 = FactoryBot.create(:media_entry)
    @media_entry_2 = FactoryBot.create(:media_entry, deleted_at: 7.months.ago)
    @media_entry_3 = FactoryBot.create(:media_entry, is_published: false, deleted_at: 7.months.ago)
    @collection_1 = FactoryBot.create(:collection)
    @collection_2 = FactoryBot.create(:collection, deleted_at: 7.months.ago)
  end

  context 'delete_soft_deleted_resources task' do
    it 'works' do
      Rake::Task["madek:delete_soft_deleted_resources"].invoke
      expect(MediaEntry.unscoped.count).to eq 1
      expect(Collection.unscoped.count).to eq 1
      expect(MediaEntry.unscoped.find_by_id(@media_entry_2.id)).to be nil
      expect(MediaEntry.unscoped.find_by_id(@media_entry_3.id)).to be nil
      expect(Collection.unscoped.find_by_id(@collection_2.id)).to be nil
    end
  end
end
