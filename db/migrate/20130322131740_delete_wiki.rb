class DeleteWiki < ActiveRecord::Migration
  def up
    drop_table :wiki_page_versions
    drop_table :wiki_pages
  end

  def down
    raise "Irreversible"
  end
end
