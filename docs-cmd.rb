require "json"
require "./docs"

if ARGV[0].to_s == ""
  puts "Must have input file as first parameter"
  exit 1
end

if ARGV[1].to_s == ""
  puts "Must have output file as second parameter"
  exit 1
end

File.open(ARGV[1], "w") do |output|
  parse_fields(ARGV[0]).each do |field|
    output << field.to_json << "\n"
  end
end
