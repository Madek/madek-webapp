object @media_entry_incomplete
attributes :id

node :filename do  |me|
  me.media_file.filename
end

node :size do |me|
  me.media_file.size
end
