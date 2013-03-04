class DropSnapshots < ActiveRecord::Migration

  class Snapshot < MediaResource
  end

  class MetaKey < ActiveRecord::Base
  end

  def up
    Snapshot.destroy_all
    MetaKey.find_by_label("description author before snapshot").try(:destroy)
  end

  def down
  end
end
