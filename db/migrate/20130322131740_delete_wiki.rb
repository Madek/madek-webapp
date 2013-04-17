class DeleteWiki < ActiveRecord::Migration
  def up
    execute 'DROP TABLE wiki_page_versions CASCADE;'
    execute 'DROP TABLE wiki_pages CASCADE;'
  end

  def down
    raise "Irreversible"
  end
end
