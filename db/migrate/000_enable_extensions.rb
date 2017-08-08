
class EnableExtensions < ActiveRecord::Migration[4.2]

  def change
    enable_extension 'pg_trgm'
    enable_extension 'uuid-ossp'
    enable_extension 'pgcrypto'
  end

end
