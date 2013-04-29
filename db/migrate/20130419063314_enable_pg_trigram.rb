class EnablePgTrigram < ActiveRecord::Migration
  def up
    execute 'CREATE EXTENSION pg_trgm'
  end

  def down
  end
end
