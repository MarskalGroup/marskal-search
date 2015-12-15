class MarskalSearch

  def help(p_key, p_wrap)
    MarskalSearch::Help.commands(p_key, p_wrap)
  end

  class Help
    @@help_content = nil
    @wrap = true


    def self.load_content
      l_erb_file = ERB.new(File.read("#{Gem.loaded_specs['marskal-search'].full_gem_path}/config/locales/marskal_search.help.en.yml"))
      @@help_content = YAML.load(l_erb_file.result(binding)).deep_symbolize_keys()
    end

    def self.commands(p_key, p_wrap= false)
      @wrap = p_wrap
      return "General Instructions Coming Soon" if p_key.nil?
      load_content() #TODO: put this check back when out of alpha mode if @@help_content.nil?

      p_key = p_key.to_sym

      l_output = command_help_template(p_key)
      puts l_output

      return
    end

    #show all valid keys in synopsis
    def self.default_synopsis(p_key)
      l_text = ''
      VALID_KEYS[p_key][:valid].each do |l_key|
        l_text += "[ :#{l_key} ] "
      end
      l_text
    end

    private

    #format text for an 80 character wide screen
    def self.format_for_terminal(p_block_text, p_tabs = "\t\t")
      l_max_length = @wrap ? 79 : 99999999
      #note we use our own notation "+\n" indicates we are concatenating two lines, so we should replace the \n with a space
      l_text = p_block_text.to_s.split(/\s!\n!\t/).join(' ')
      l_text.gsub!("\\n", "\n")
      l_text.gsub!("+\n", ' ')

      p_tabs = p_tabs.gsub("\t", '  ')
      l_max_length = l_max_length - p_tabs.length

      l_formatted_str = ''
      until l_text.blank? do
        l_char_to_add = "\n"  #default to add a new line char
        l_line = l_text.gsub("\t", '  ')[0..l_max_length]  #adjust for tabs, which we will later replace for spaces

        #these lines discover the space in the line, last newline in the line or the need of the string. Ir will use
        #what ever the minimum value is as long as it is not nil
        l_last_space = l_line.rindex(' ')
        l_first_newline = l_line.index("\n")
        unless l_first_newline.nil? #use new line if we found 1
          l_last_space  = l_first_newline
          l_char_to_add = ''  #we already have our new line, so we don't need 2
        else
          l_last_space = l_line.length if l_last_space.nil? || l_text.length <= l_max_length #chedk if we are on last line
        end

        l_new_str = l_text.slice!(0, l_last_space+1)
        l_formatted_str += "#{p_tabs}#{l_new_str}#{l_char_to_add}"
      end
      l_formatted_str.gsub("\\t", '  ')
    end

    #format array of options for 80 character terminal mode
    def self.format_options_for_terminal(p_options)
      l_result = ''
      l_ctr = 0
      p_options.each do |k, p_option|
        l_result += "\n\n" unless l_ctr == 0
        l_result  += format_for_terminal(p_option[:name])
        l_result  += "#{format_for_terminal(p_option[:description], "\t\t\t")}"
        l_ctr += 1
      end
      l_result
    end


    #template for help for a command
    def self.command_help_template(p_key_symbol)
      p_content = @@help_content[p_key_symbol]
      p_key = p_content[:name]
      <<-OUTSTR

NAME:

    #{p_key} - #{p_content[:tip]}

SYNOPSIS:

    #{p_key} - #{p_content[:synopsis]}

    Getting Value:
      #{p_content[:getter]}

    Setting Value:
      set_#{p_content[:setter]}

DESCRIPTION:

#{format_for_terminal(p_content[:description])}

OPTIONS

#{format_options_for_terminal(p_content[:options])}

EXAMPLES:

#{format_for_terminal(p_content[:examples])}
--------------------- END Help #{p_key} ---------------------

      OUTSTR

    end

  end #help

end #marskalsearch

