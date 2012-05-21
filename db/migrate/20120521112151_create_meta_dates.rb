class CreateMetaDates < ActiveRecord::Migration
  def change
    create_table :meta_dates do |t|

      t.datetime :timestamp
      t.string :timezone
      t.string :free_text

    end
  end
end
