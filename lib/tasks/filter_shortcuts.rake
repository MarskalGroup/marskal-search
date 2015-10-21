namespace :marskal_search do

  desc 'Display Column Filter ShortCuts'
  task :shortcuts do
    spec = Gem::Specification.find_by_name("marskal-search")
    doc_file = "#{spec.gem_dir}/supplimental_documentation/SHORTCUTS.md"

    # puts doc_file

    puts "\n\n"
    dashed_line_length = 20  #defaulkt to 20 charcters long
    l_file = File.open(doc_file, "r").each_line do |line|
      if line == "---\n"
        l_dashed_line = ''
        dashed_line_length.times { l_dashed_line += '-'}
        puts l_dashed_line
      elsif line[0] == '#'
        idx = line.index(' ')
        puts line[idx..line.length].strip
      elsif line == "```\n"
        puts "\n"
        next
      elsif line[0..6].downcase == "back to"
        next
      else
        puts line.gsub("\n", '')
      end
      dashed_line_length = [dashed_line_length, line.length].max if line.strip.length > 0

    end
    l_file .close

  end
end