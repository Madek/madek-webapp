def fix_string(broken_string)
  fixed_string = []
  broken_string.chars.each do |c|
    char = case c
      when "\xFC" then "%C3%BC" # ü
      when "\xE4" then "%C3%A4" # ä
      else c # Unknown -- did not appear in our data set at all
    end
    fixed_string << char
  end
  return fixed_string.join
end

percent = MediaFile.where("filename ILIKE '%\\%%'")
broken = []
percent.each do |p|
  begin
    CGI::unescape(p.filename)
  rescue
    broken << p
  end
end

broken.each do |b|
  b.filename = fix_string(b.filename)
  b.save
end
