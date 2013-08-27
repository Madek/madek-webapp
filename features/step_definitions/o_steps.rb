Then /^Only the files with missing metadata are listed$/ do
  expect(all("ul.ui-resources li",visible: true).size).to eq 2
end
