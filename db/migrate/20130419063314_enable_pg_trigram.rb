class EnablePgTrigram < ActiveRecord::Migration
  def up
    execute 'CREATE EXTENSION IF NOT EXISTS pg_trgm'
  end

  def down
  end
end
