require 'json'

data = JSON.parse(File.read("data.json"))
specarr = Array.new

# Set values for all fields
counter = 1
data.first.keys.each do |k|
  itemhash = Hash.new
  itemhash["Field Name"] = k.gsub("-", "_")
  itemhash["Human Readable Name"] = k.gsub("_", " ")
  itemhash["Type"] = data.first[k].match(/\d{4}-\d{2}-\d{2}/) ? "Date" : "String"
  itemhash["Mapping"] = "english"
  itemhash["Facet?"] = data.first[k].split(" ").length > 4 ? "No" : "Yes"
  itemhash["In Table?"] = "Yes"
  itemhash["Show by default in table?"] = counter < 4 ? "Yes" : "No"
  itemhash["Searchable?"] = "Yes"
  itemhash["In Doc?"] = "Yes"
  itemhash["Form Params"] = itemhash["Type"] == "Date" ? [k, "end_"+k] : k
  itemhash["Size"] = "1000"
  itemhash["Location"] = counter.to_s
  itemhash["Item_Field"] = "No"
  specarr.push(itemhash)

  counter += 1
end

puts JSON.pretty_generate(specarr)
