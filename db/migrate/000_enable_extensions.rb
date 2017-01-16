
class EnableExtensions < ActiveRecord::Migration

  def change
    enable_extension 'pg_trgm'
    enable_extension 'uuid-ossp'
    enable_extension 'pgcrypto'
  end

end
