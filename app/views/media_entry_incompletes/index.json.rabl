collection @media_entry_incompletes
attributes :id

node :file_name do  |me|
  me.media_file.filename
end

node :size do |me|
  me.media_file.size
end
