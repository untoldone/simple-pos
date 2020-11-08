require "./docs.rb"
require "csv"

if ARGV[0].to_s == ""
  puts "Must have input documentation file as first parameter"
  exit 1
end

if ARGV[1].to_s == ""
  puts "Must have input file as second parameter"
  exit 1
end

if ARGV[2].to_s == ""
  puts "Must have output file as third parameter"
  exit 1
end

fmap = {}
headers = []

fields = parse_fields(ARGV[0])
fields.each do |f|
  catmap = fmap[f[:category_type]] ||= {}
  catmap[f[:sas_name]] = f
  headers << f[:title]

  if f[:values]
    headers << f[:title] + " Value"
  end
end

headers.uniq!
header_positions = {}
headers.each_with_index do |header, index|
  header_positions[header] = index
end

count = 0

CSV.open(ARGV[2], "w") do |output|
  output << headers

  CSV.foreach(ARGV[1], encoding: "ISO-8859-1", headers: true) do |row|
    count += 1

    if count % 10000 == 0
      puts "completed #{count}..."
    end

    result = Array.new(headers.length)

    row.headers.each do |key|
      meta = fmap[row["PRVDR_CTGRY_CD"]][key]

      if meta == nil
        next
      end

      row_index = header_positions[meta[:title]]
      result[row_index] = row[key]

      if meta[:values]
        value_title = meta[:title] + " Value"
        row_index = header_positions[value_title]
        result[row_index] = meta[:values][row[key]]
      end
    end

    output << result
  end
end

puts "completed #{count}"