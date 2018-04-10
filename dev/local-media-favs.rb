#!/usr/bin/env bundle exec rails runner

# get all media files (previews + originals) from users favs.
# useful for local/offline dev based on prod data
user_arg = ARGV[0]
fail unless user_arg.present?

user = User.find_by(login: user_arg) || User.find_by(email: user_arg) || User.find_by(id: user_arg)
fail unless user.present?

files = [user.favorite_media_entry_ids, 'e2d24e43-552d-4893-b7e9-032333f21618'].flatten.map{|id| MediaEntry.find(id)}
.map(&:media_file).map do |mf|
  [
    # File.join(mf.guid.first, mf.guid),
    mf.previews.map(&:filename).map { |f| File.join(f.first, f)}
  ]
end.flatten

puts files
