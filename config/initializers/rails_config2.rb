Settings.add_source!  Rails.root.join("config","dropbox.yml").to_s
Settings.add_source!  Rails.root.join("config","dropbox.local.yml").to_s
Settings.add_source!  Rails.root.join("config","zencoder.yml").to_s
Settings.add_source!  Rails.root.join("config","zencoder.local.yml").to_s
Settings.reload!
