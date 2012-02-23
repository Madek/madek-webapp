When /^I atach a file with a size of 0 bytes$/ do
  begin
    path = File.join(::Rails.root, "tmp/file_with_zero_bytes.jpg") 
    `dd if=/dev/zero of=#{path} count=0` 
    attach_file(find("input[type='file']")[:id], path)
  ensure
    File.delete path
  end
  
  wait_for_css_element(".ui-dialog.zero_bytes_error")
end

