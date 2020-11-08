def parse_fields(input_file, debug = false)
  output = []

  current_type = "01"
  reading_field = false
  reading_title = false
  reading_fields = false
  reading_description = false
  description = []
  title = []
  field = {}


  File.foreach(ARGV[0]).with_index do |line, line_number|
    if line.strip.start_with?(/\*[\*|\s]/) ||
        line.strip == "" ||
        line.strip.start_with?("SHORT") ||
        line.strip.start_with?("DATE") ||
        line.strip.start_with?("(SEE POSITIONS 3-4)") ||
        line.strip.start_with?("3-4)") ||
        line.strip.start_with?("Intermediate Care Facility/Individuals with Intellectual Disabilities,")
      # puts line
      next
    end

    if line.strip.match(/CATEGORY = "(\d\d)"/)
      current_type = line.strip.match(/CATEGORY = "(\d\d)"/)[1]
      next
    end

    if reading_title && line.strip.start_with?("Description:")
      reading_title = false
      field[:title] = title.join(" ")
      title = []
    elsif reading_title
      title << line.strip

      next
    end

    if reading_description && line.strip.start_with?("SAS Name:")
      reading_description = false
      field[:description] = description.join(" ")
      description = []

      matches = line.strip.match(/^SAS Name:\s+([\w_]+)$/)
      field[:sas_name] = matches[1]

      next
    elsif reading_description
      description << line.strip

      next
    end

    if line.strip.start_with?("Description:")
      matches = line.strip.match("Description:(.+)")
      description << matches[1].strip
      reading_description = true

      next
    end

    if line.strip.start_with?("COBOL Name:")
      matches = line.strip.match(/^COBOL Name:\s+([\w\-]+)$/)
      field[:cobol_name] = matches[1]

      next
    end

    if line.strip.start_with?("VALUES:")
      reading_fields = true
      field[:values] = {}
    end

    if reading_fields && line.strip.match(/(VALUES:)?\s*([^=]+)=(.+)/)
      matches = line.strip.match(/(VALUES:)?\s*([^=]+)=(.+)/)
      field[:values][matches[2].strip] = matches[3].strip

      next
    else
      reading_fields = false
      # Don't go to next, next field may be content
    end

    if line.strip.match(/^(.+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\w+)$/)
      if reading_field
        output << field
        field = {}
      end

      reading_field = true

      matches = line.strip.match(/^(.+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\w+)$/)
      title << matches[1].strip

      field[:length] = matches[2]
      field[:start_pos] = matches[3]
      field[:end_pos] = matches[4]
      field[:type] = matches[5].strip

      field[:category_type] = current_type

      reading_title = true

      next
    end

    # Ignore field
    puts "#{line_number}: #{line}" if debug
  end

  output
end